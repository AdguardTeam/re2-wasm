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
# Stage: test
# Runs lint, compiles WASM with emscripten, compiles TypeScript, runs tests.
# ============================================================================
FROM source AS test

ARG BUILD_RUN_ID=""

RUN echo "${BUILD_RUN_ID}" > /tmp/.build-run-id && \
    mkdir -p /out && \
    npm run lint && \
    make -j$(nproc) && npx tsc && cp -r wasm build/ && \
    node ./third_party/node-re2/tests/tests.js

FROM scratch AS test-output
COPY --from=test /out/ /

# ============================================================================
# Stage: build
# Compiles WASM with emscripten, compiles TypeScript, and packs .tgz for
# npm publish.
# ============================================================================
FROM source AS build

ARG BUILD_RUN_ID=""

RUN echo "${BUILD_RUN_ID}" > /tmp/.build-run-id && \
    make -j$(nproc) && npx tsc && cp -r wasm build/ && \
    npm pack && mv adguard-re2-wasm-*.tgz re2-wasm.tgz && \
    mkdir -p /out/artifacts && \
    mv re2-wasm.tgz /out/artifacts/

FROM scratch AS build-output
COPY --from=build /out/artifacts/ /
