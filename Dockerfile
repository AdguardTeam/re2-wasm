FROM emscripten/emsdk:3.1.61 AS base
SHELL ["/bin/bash", "-lc"]

WORKDIR /re2-wasm

# ============================================================================
# Stage: deps
# Cached until package.json/package-lock.json changes
# ============================================================================
FROM base AS deps

COPY package.json package-lock.json ./

# --ignore-scripts: package.json has "prepare": "npm run compile" which must not
# run in CI (requires emscripten toolchain and full C++ compilation at install
# time).
RUN npm ci --ignore-scripts

# ============================================================================
# Stage: source
# Full source copy — parent for all lint/test/build stages
# ============================================================================
FROM deps AS source

COPY . /re2-wasm

# ============================================================================
# Stage: lint
# Runs gts lint
# ============================================================================
FROM source AS lint

ARG BUILD_RUN_ID=""

RUN echo "${BUILD_RUN_ID}" > /tmp/.build-run-id && \
    mkdir -p /out && \
    touch /out/lint.txt && \
    npm run lint

FROM scratch AS lint-output
COPY --from=lint /out/ /

# ============================================================================
# Stage: test
# Compiles WASM with emscripten, compiles TypeScript, then runs tests
# Always exits 0 — exit code stored in /out/exit-code.txt for Bamboo to check
# ============================================================================
FROM source AS test

ARG BUILD_RUN_ID=""

RUN echo "${BUILD_RUN_ID}" > /tmp/.build-run-id && \
    mkdir -p /out && \
    make -j$(nproc) && npx tsc && cp -r wasm build/ && node scripts/build-info.js && \
    { node ./third_party/node-re2/tests/tests.js; echo $? > /out/exit-code.txt; }

FROM scratch AS test-output
COPY --from=test /out/ /

# ============================================================================
# Stage: build
# Compiles WASM with emscripten, compiles TypeScript, packs .tgz for npm
# publish, and exports build.txt for Bamboo variable injection
# ============================================================================
FROM source AS build

ARG BUILD_RUN_ID=""

RUN echo "${BUILD_RUN_ID}" > /tmp/.build-run-id && \
    make -j$(nproc) && npx tsc && cp -r wasm build/ && node scripts/build-info.js && \
    npm pack && mv adguard-re2-wasm-*.tgz re2-wasm.tgz && \
    mkdir -p /out/artifacts && \
    mv re2-wasm.tgz /out/artifacts/ && \
    cp build/build.txt /out/artifacts/

FROM scratch AS build-output
COPY --from=build /out/ /
