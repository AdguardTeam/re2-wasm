# @adguard/re2-wasm [![NPM version][npm-img]][npm-url]

[npm-img]: https://img.shields.io/npm/v/@adguard/re2-wasm.svg
[npm-url]: https://npmjs.org/package/@adguard/re2-wasm

> Google's RE2 library distributed as a WASM module patched by AdGuard.

## Description

**@adguard/re2-wasm** is a fork of Google's [re2-wasm](https://github.com/google/re2-wasm) that adds a configurable
maximum memory limit for regular expressions. It compiles Google's [RE2](https://github.com/google/re2) C++ library to
WASM via Emscripten and exposes it as a drop-in replacement for JavaScript's `RegExp`.

This library is for JavaScript and TypeScript developers who need to handle user-supplied regular expressions
safely. The built-in `RegExp` engine can run in exponential time with a vulnerable regular expression and
"evil input", leading to [Regular Expression Denial of Service
(ReDoS)](https://www.owasp.org/index.php/Regular_expression_Denial_of_Service_-_ReDoS). RE2 guarantees
linear-time matching, protecting your application from ReDoS attacks. The AdGuard fork adds bounded memory
usage via the `maxMem` option — the engine throws an error if a match attempt exceeds the configured memory
limit, preventing runaway resource consumption.

`RE2`'s regular expression language is almost a superset of what is provided by `RegExp`
(see [Syntax](https://github.com/google/re2/wiki/Syntax)), but it lacks two features: backreferences and lookahead
assertions. See [Differences from RegExp](#differences-from-regexp) for details.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Overview](#api-overview)
- [Usage Examples](#usage-examples)
- [Differences from RegExp](#differences-from-regexp)
- [Documentation](#documentation)

---

## Installation

```bash
npm install @adguard/re2-wasm
```

Requires Node.js ≥ 10 or a browser with WASM support. The package has zero runtime dependencies — all functionality
comes from the compiled WASM module.

## Quick Start

```js
const { RE2 } = require('@adguard/re2-wasm');

const re = new RE2('hello (\\w+)', 'u');
const result = re.exec('hello world');
// result[0]: 'hello world'
// result[1]: 'world'
// result.index: 0
console.log(result[0]); // 'hello world'
```

Or with ES modules:

```js
import { RE2 } from '@adguard/re2-wasm';

const re = new RE2('\\d+', 'gu');
'abc 123 def 456'.match(re); // ['123', '456']
```

## API Overview

The `RE2` class emulates the standard `RegExp` interface. It can be used as a drop-in replacement in most cases.

### Constructor

```ts
new RE2(pattern: string | RegExp | RE2, flags?: string, maxMem?: number)
```

| Parameter | Type | Description |
| --- | --- | --- |
| `pattern` | `string`, `RegExp`, or `RE2` | The regular expression pattern. Accepts existing `RegExp` or `RE2` objects. |
| `flags` | `string` | Standard RegExp flags (`g`, `i`, `m`, `s`, `u`, `y`). The `u` flag is **required**. |
| `maxMem` | `number` | Maximum memory in bytes the regex engine can use. Defaults to `0` (no limit). If exceeded, throws an error. |

### Properties

| Property | Type | Description |
| --- | --- | --- |
| `lastIndex` | `number` | Index at which to start the next match (used with `g` and `y` flags). |
| `global` | `boolean` | Whether the `g` flag is set. |
| `ignoreCase` | `boolean` | Whether the `i` flag is set. |
| `multiline` | `boolean` | Whether the `m` flag is set. |
| `dotAll` | `boolean` | Whether the `s` flag is set. |
| `unicode` | `boolean` | Whether the `u` flag is set. Always `true`. |
| `sticky` | `boolean` | Whether the `y` flag is set. |
| `source` | `string` | The original pattern string. |
| `flags` | `string` | The flags string. |
| `internalSource` | `string` | The pattern after translation to RE2 syntax (read-only, for debugging). |

### Methods

| Method | Description |
| --- | --- |
| `exec(str: string): RE2ExecArray \| null` | Executes a search for a match. Returns a match array or `null`. |
| `test(str: string): boolean` | Tests for a match. Returns `true` or `false`. |
| `toString(): string` | Returns the regex as a string (`/pattern/flags`). |
| `match(str: string): RE2MatchArray \| null` | Matches the string against the regex. Equivalent to `String.prototype.match`. |
| `search(str: string): number` | Searches for a match. Equivalent to `String.prototype.search`. |
| `replace(str: string, replacer: string \| function): string` | Replaces matches. Equivalent to `String.prototype.replace`. |
| `split(str: string, limit?: number): (string \| undefined)[]` | Splits the string. Equivalent to `String.prototype.split`. |

The `RE2` class also supports well-known symbols, so `String` methods work directly:

```js
const re = new RE2('\\d+', 'u');
'abc 123'.match(re);        // ['123', index: 4, input: 'abc 123']
'abc 123'.search(re);       // 4
'abc 123'.replace(re, 'X'); // 'abc X'
'abc 123'.split(re);        // ['abc ', '']
```

## Usage Examples

### Constructing from a RegExp object

```js
const orig = /\w+/gu;
const re = new RE2(orig);
// Flags and pattern are copied from the original
console.log(re.flags); // 'gu'
```

### Using the maxMem option to bound memory

```js
// Limit the regex engine to 4 KB of memory
const re = new RE2('a*b*c*d*e*f*g*h*i*j*k*l*m*n*o*p*q*r*s*t*u*v*w*x*y*z*', 'u', 4096);
try {
  re.exec('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
} catch (e) {
  console.log('Pattern exceeded memory limit');
}
```

### Named capture groups

```js
const re = new RE2('(?P<word>\\w+) (?P<number>\\d+)', 'u');
const result = re.exec('hello 42');
console.log(result.groups.word);   // 'hello'
console.log(result.groups.number); // '42'
```

### Using Symbol.matchAll

```js
const re = new RE2('\\w+', 'gu');
for (const match of 'one two three'.matchAll(re)) {
  console.log(match[0]);
}
// 'one'
// 'two'
// 'three'
```

### Replacing with a function

```js
const re = new RE2('(\\d+)', 'gu');
const result = re.replace('a 10 b 20 c 30', (match, n) => String(Number(n) * 2));
console.log(result); // 'a 20 b 40 c 60'
```

### Falling back to RegExp for unsupported patterns

```js
const pattern = /(a)+(b)*\\1/u;
let re;
try {
  re = new RE2(pattern);
} catch (e) {
  // Pattern uses backreferences — fall back to RegExp
  re = pattern;
}
const result = re.exec('aabbaabb');
```

## Differences from RegExp

### Backreferences and lookahead assertions not supported

`RE2` does not support backreferences (`\\1`, `\\2`, etc.) or lookahead/lookbehind assertions (`(?=...)`, `(?<=...)`,
`(?!...)`, `(?<!...)`). Attempting to use these features throws a `SyntaxError`. If your patterns require them,
fall back to `RegExp` (see the [fallback example](#falling-back-to-regexp-for-unsupported-patterns) above).

### Unicode flag is mandatory

The `RE2` engine always works in Unicode mode. The `u` flag must be passed when constructing an `RE2` instance:

```js
new RE2('\\w+');           // throws Error: "u" flag must be passed
new RE2('\\w+', 'u');      // OK
```

### Memory limit

The `maxMem` constructor parameter (an AdGuard extension) restricts how much memory the regex engine can allocate
during matching. If the limit is exceeded, the engine throws an error. Pass `0` (the default) for no limit.

### Dot behavior

In RE2, `.` matches any character including `\\n`, regardless of whether the `m` or `s` flags are set. This is
equivalent to `RegExp`'s `s` (dotAll) flag always being on:

```js
const re = new RE2('a.b', 'u');
console.log(re.exec('a\\nb')); // ['a\\nb']
console.log(/a.b/u.exec('a\\nb')); // null
```

### Anchors in multiline mode

In multiline mode, `$` in RE2 does not match between `\\r` and `\\n` when the string ends with `\\r\\n`:

```js
const re = new RE2('a$', 'mu');
re.exec('a\\r\\n'); // null — RE2 does not match between \\r and \\n
/a$/mu.exec('a\\r\\n'); // ['a'] — RegExp matches between \\r and \\n
```

### `compile()` method

`RegExp.prototype.compile()` is deprecated and not implemented in `RE2`. Calling it throws an error. Create a new
`RE2` instance instead.

### `d` flag (hasIndices)

The `hasIndices` (`d`) flag is not supported. Use `RegExp` with the `d` flag if you need start and end indices of
capture groups.

---

## Documentation

- [Development](DEVELOPMENT.md) — how to set up and contribute
- [Changelog](CHANGELOG.md) — version history
- [LLM agent rules](AGENTS.md) — AI-assisted development guidelines
