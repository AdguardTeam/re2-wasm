# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic Versioning].

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [1.2.1] - 2026-07-10

## [1.2.1] - 2026-07-10

[Unreleased]: https://github.com/AdguardTeam/re2-wasm/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/AdguardTeam/re2-wasm/compare/v1.2.1...v1.2.1
[1.2.1]: https://github.com/AdguardTeam/re2-wasm/compare/v1.2.0...v1.2.1

## [1.2.0] - 2024-06-19

### Added

- `maxMem` constructor argument that limits the maximum memory (in bytes) a
  regular expression can use during matching. When exceeded, a `SyntaxError`
  is thrown with the message "pattern too large".
  ([1ceaced](https://github.com/AdguardTeam/re2-wasm/commit/1ceaced)).

### Changed

- Updated Emscripten SDK to v14
  ([a2ef140](https://github.com/AdguardTeam/re2-wasm/commit/a2ef140))
- Build process now uses a Docker-based Emscripten image for C++ → WASM
  compilation
- Updated `package.json` metadata for publishing under the `@adguard` scope

[1.2.0]: https://github.com/AdguardTeam/re2-wasm/compare/v1.1.0...v1.2.0

## [1.1.0] - 2022-11-30

### Added

- Support for String.prototype.matchAll()
  ([f8dfe27](https://github.com/google/re2-wasm/commit/f8dfe27716747914585482f6b70f353b2f2507ce))

[1.1.0]: https://github.com/google/re2-wasm/compare/v1.0.2...v1.1.0

## [1.0.2] - 2021-09-14

### Fixed

- Don't generate unhandled exception and rejection handlers
  ([47df5f5](https://www.github.com/google/re2-wasm/commit/47df5f581089c4f9210188f54374b2285446936b))

[1.0.2]: https://www.github.com/google/re2-wasm/compare/v1.0.1...v1.0.2

## [1.0.1] - 2021-02-11

### Fixed

- Use correct package name in README
  ([7aed127](https://www.github.com/google/re2-wasm/commit/7aed12756162a005b75c63e115ce1a78098c2a10))

[1.0.1]: https://www.github.com/google/re2-wasm/compare/v1.0.0...v1.0.1

## 1.0.0 - 2021-02-05

### Added

- initial release ([65d7c80](https://www.github.com/google/re2-wasm/commit/65d7c805511af0d95e3252bb7933020cbe7b0d12))
