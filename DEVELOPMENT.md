# Development Guide

## Table of Contents

- [Prerequisites](#prerequisites)
    - [Required Tools](#required-tools)
    - [Optional Tools](#optional-tools)
- [Getting Started](#getting-started)
    - [Clone the Repository](#clone-the-repository)
    - [Install Dependencies](#install-dependencies)
    - [Compile the Project](#compile-the-project)
    - [Verify the Build](#verify-the-build)
- [Development Workflow](#development-workflow)
    - [Branching Strategy](#branching-strategy)
    - [Code Style](#code-style)
    - [Running Tests](#running-tests)
    - [Pull Request Process](#pull-request-process)
- [Common Tasks](#common-tasks)
    - [Compiling C++ to WASM (Docker)](#compiling-c-to-wasm-docker)
    - [Compiling C++ to WASM (Native Emscripten)](#compiling-c-to-wasm-native-emscripten)
    - [Compiling TypeScript](#compiling-typescript)
    - [Full Build Pipeline](#full-build-pipeline)
    - [Linting](#linting)
    - [Auto-fixing Lint Issues](#auto-fixing-lint-issues)
    - [Cleaning Build Artifacts](#cleaning-build-artifacts)
- [Project Architecture](#project-architecture)
    - [Layers](#layers)
    - [Build Output](#build-output)
- [Troubleshooting](#troubleshooting)
    - [Submodule Not Cloned](#submodule-not-cloned)
    - [Emscripten Not Found](#emscripten-not-found)
    - [Docker Image Not Available (Apple Silicon)](#docker-image-not-available-apple-silicon)
    - [Tests Fail After Changes](#tests-fail-after-changes)
    - [Lint Errors After Edit](#lint-errors-after-edit)
- [Additional Resources](#additional-resources)

## Prerequisites

### Required Tools

| Tool              | Version                         | Purpose                                  |
| ----------------- | ------------------------------- | ---------------------------------------- |
| Node.js           | ≥ 10                            | Runtime for compiled JS/WASM             |
| npm               | ≥ 6 (bundled with Node.js)      | Package manager                          |
| Git               | ≥ 2                             | Version control                          |
| Emscripten (emcc) | latest (`emsdk install latest`) | Compile C++ to WASM                      |
| Docker            | ≥ 20                            | Alternative WASM compilation environment |

### Optional Tools

| Tool | Purpose                                                          |
| ---- | ---------------------------------------------------------------- |
| make | Parallel C++ compilation (used by both native and Docker builds) |

## Getting Started

### Clone the Repository

The repository includes a git submodule for the RE2 C++ library. You **must**
clone recursively:

```sh
git clone --recursive git@github.com:AdguardTeam/re2-wasm.git
```

If you already cloned without `--recursive`, initialize the submodule manually:

```sh
git submodule update --init --recursive
```

### Install Dependencies

```sh
cd re2-wasm
npm install
```

This installs the Node.js dev dependencies (@types/node, gts, heya-unit,
markdownlint, markdownlint-cli, TypeScript). The `prepare` script runs
`npm run compile` automatically, which requires Docker (or a native Emscripten
SDK) to build the WASM module. To install only the dev dependencies without
compiling, pass `--ignore-scripts` (this is what CI does); locally, compile the
project separately as described in [Common Tasks](#common-tasks).

### Compile the Project

You have two options for compiling the C++ RE2 library to WASM:

#### Option A: Docker (recommended)

```sh
npm run compile-emcc
```

This runs Emscripten inside a Docker container. No local Emscripten SDK needed.

#### Option B: Native Emscripten

First, install the Emscripten SDK:

```sh
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
```

Then compile:

```sh
make -j12
```

After the WASM module is compiled (either way), compile the TypeScript:

```sh
npm run compile-ts
```

### Verify the Build

```sh
npm test
```

This runs the full test suite using heya-unit. If all tests pass, the
build is working correctly.

## Development Workflow

### Branching Strategy

- Create feature branches from `master`
- Name branches with a descriptive prefix: `fix/`, `feat/`, `chore/`
- Keep branches focused on a single change

### Code Style

This project uses **gts** (Google TypeScript Style), which bundles ESLint and
Prettier. Configuration is inherited from gts — do not modify `.eslintrc.json`
or `.prettierrc.js`.

Markdown files are linted with **markdownlint**.

To check your code:

```sh
npm run lint
```

To auto-fix TypeScript formatting issues:

```sh
npm run fix
```

### Running Tests

```sh
npm test
```

This command:

1. Compiles the project (`pretest` → `npm run compile`)
2. Runs the test suite (`test` → `node ./third_party/node-re2/tests/tests.js`)
3. Runs the linter (`posttest` → `npm run lint`)

The test suite lives in `third_party/node-re2/tests/` and covers:
exec, match, matchAll, search, replace, split, test, groups, source, toString,
prototype, symbols, general, and invalid input validation.

Key test file: `test_invalid.js` — verifies memory limits, backreference
rejection, and lookahead assertion rejection.

### Pull Request Process

1. Ensure all tests pass: `npm test`
2. Ensure linting passes: `npm run lint`
3. Use [conventional commits](https://www.conventionalcommits.org/) for commit
   messages
4. Open a PR against `master` on GitHub
5. All submissions require code review
6. Contributions must be accompanied by a Contributor License Agreement (CLA)
   — see [docs/contributing.md](docs/contributing.md)

## Common Tasks

### Compiling C++ to WASM (Docker)

```sh
npm run compile-emcc
```

Runs `docker run --rm -v $(pwd):/src emscripten/emsdk make -j12` inside the
official Emscripten Docker image. Output: `wasm/re2.js`.

### Compiling C++ to WASM (Native Emscripten)

```sh
make -j12
```

Runs `emcc` with `--bind -s WASM=1` flags, compiling `wrap/re2_wrap.cc` and all
RE2 source files from `deps/re2/`. Output: `wasm/re2.js`.

Emscripten flags used:

| Flag                          | Purpose                              |
| ----------------------------- | ------------------------------------ |
| `--bind`                      | Enable embind for C++/JS interop     |
| `-s WASM=1`                   | Target WebAssembly                   |
| `-s WASM_ASYNC_COMPILATION=0` | Disable async WASM compilation       |
| `-s NODEJS_CATCH_EXIT=0`      | Disable Node.js exit catching        |
| `-s NODEJS_CATCH_REJECTION=0` | Disable unhandled rejection catching |
| `-I deps/re2`                 | Include path for RE2 headers         |

### Compiling TypeScript

```sh
npm run compile-ts
```

Runs `tsc` and copies the `wasm/` directory into `build/`. Output: compiled JS
in `build/src/`.

### Full Build Pipeline

```sh
npm run compile
```

Equivalent to running sequentially:

1. `make -j12` — C++ → WASM
2. `tsc` — TypeScript → JS
3. `cp -r wasm build/` — copy WASM assets

### Linting

```sh
# TypeScript linting only
npm run lint:ts

# Markdown linting only
npm run lint:md

# Both
npm run lint
```

### Auto-fixing Lint Issues

```sh
npm run fix
```

Runs `gts fix src/*.ts` to auto-correct TypeScript formatting.

### Cleaning Build Artifacts

```sh
npm run clean
```

Removes the `build/` directory and other generated files via `gts clean`.

## Project Architecture

### Layers

The project uses a **layered architecture** with strict downward dependencies:

```text
JavaScript API (src/re2.ts)
    ↓
WASM Bridge (wasm/re2.js, wasm/re2.d.ts)
    ↓
C++ Bindings (wrap/re2_wrap.cc)
    ↓
RE2 Library (deps/re2/)
```

| Layer          | Files                          | Purpose                                          |
| -------------- | ------------------------------ | ------------------------------------------------ |
| JavaScript API | `src/re2.ts`                   | `RE2` class implementing the `RegExp` interface  |
| WASM Bridge    | `wasm/re2.js`, `wasm/re2.d.ts` | Compiled WASM module and TypeScript declarations |
| C++ Bindings   | `wrap/re2_wrap.cc`             | Emscripten embind wrappers for RE2 C++ objects   |
| RE2 Library    | `deps/re2/`                    | Google's RE2 regex engine (vendored submodule)   |

Key architectural details:

- `src/re2.ts` exports the `RE2` class, which translates JS regex syntax to
  RE2 syntax via `translateRegExp()` before passing patterns to the WASM layer.
- `wrap/re2_wrap.cc` defines the `WrappedRE2` class using Emscripten embind,
  wrapping RE2 C++ objects with WASM-compatible interfaces (no out-parameters).
- The `maxMem` parameter flows from the `RE2` constructor through `WrappedRE2`
  to `re2::RE2::Options::set_max_mem()`.

For a detailed explanation of the intermediate API design, see
[docs/intermediate_API_design.md](docs/intermediate_API_design.md).

### Build Output

After a full compile, the `build/` directory contains:

```text
build/
├── src/
│   ├── re2.js          # Compiled TypeScript
│   ├── re2.d.ts        # TypeScript declarations
│   └── re2.js.map      # Source maps
└── wasm/
    ├── re2.js          # Compiled WASM module
    └── re2.d.ts        # WASM type declarations
```

## Troubleshooting

### Submodule Not Cloned

**Symptom**: `deps/re2/` directory is empty, build fails with missing RE2
source files.

**Solution**:

```sh
git submodule update --init --recursive
```

### Emscripten Not Found

**Symptom**: `make` fails with `emcc: command not found`.

**Solution**: Either:

- Install Emscripten SDK locally (see [Getting Started](#getting-started)), or
- Use Docker-based compilation: `npm run compile-emcc`

### Docker Image Not Available (Apple Silicon)

**Symptom**: `npm run compile-emcc` fails on macOS with Apple Silicon (M1/M2/M3)
because the `emscripten/emsdk` image does not support ARM64.

**Solution**: Install Emscripten SDK natively (see [Getting Started](#getting-started)).
Then run `make -j12` directly instead of using `npm run compile-emcc`.

### Tests Fail After Changes

**Symptom**: `npm test` reports test failures after modifying source code.

**Solution**:

1. Rebuild the full project: `npm run compile`
2. Check that incremental TypeScript compilation isn't using stale output:
   `npm run clean && npm run compile`
3. Verify your changes against the test expectations in
   `third_party/node-re2/tests/`

### Lint Errors After Edit

**Symptom**: `npm run lint` reports formatting or style violations.

**Solution**:

```sh
npm run fix    # Auto-correct TypeScript formatting
npm run lint   # Re-check
```

For Markdown lint violations, fix them manually following the rules in
[AGENTS.md](AGENTS.md#markdown-formatting).

## Additional Resources

- [README.md](README.md) — user-facing documentation and API reference
- [AGENTS.md](AGENTS.md) — LLM agent guidance and code guidelines
- [CHANGELOG.md](CHANGELOG.md) — release history
- [docs/contributing.md](docs/contributing.md) — contribution guidelines and CLA
- [docs/intermediate_API_design.md](docs/intermediate_API_design.md) — API design
  documentation
- [Google RE2 Syntax](https://github.com/google/re2/wiki/Syntax) — RE2 regex
  syntax reference
- [Emscripten Documentation](https://emscripten.org/docs/) — Emscripten SDK
  documentation
- [node-re2](https://github.com/uhop/node-re2) — original Node.js RE2 bindings
  that inspired this project
