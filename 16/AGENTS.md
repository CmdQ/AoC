# AGENTS.md

## Overview

Advent of Code 2016 solutions in **Racket**. This is a learning project — the goal is to learn Racket by solving puzzles.

**Important:** Do not implement solutions or write code unless explicitly asked. When answering questions, give general guidance, explain concepts, and point in the right direction without solving the problem.

## Setup

This uses **minimal Racket**. Packages must be installed manually:
```bash
raco pkg install --auto rackunit-lib  # needed for raco test
raco pkg install --auto debug axe \
    threading \
    priority-queue \
    htdp-lib  # provides 2htdp/image
```

## Running and Testing

```bash
# Run a day's solution (executes top-level code)
racket day01.rkt

# Run tests (each file has a `module+ test` section)
raco test day01.rkt

# Run all tests
raco test .

# Run the main submodule (visualizations live here)
racket -t day13.rkt -m
```

## Code Conventions

**Structure of a day file:**
- `#lang racket` (or `racket/base` for library modules)
- Input parsing at the top (typically `file->string` or `file->lines` on `inputNN.txt`)
- Part 1 as `(solve1)`, Part 2 as `(solve2)`
- Sections separated by `;;;;` comment banners: Part 1, Part 2, Visualization, Tests
- Tests in `(module+ test ...)` using `rackunit`, with known answers as regression checks

**Key packages used:** `threading` (~> macro for pipelines), `2htdp/image` (visualizations), `data/priority-queue`, `openssl/md5`.

**Local library modules** (required via relative path `"module.rkt"`):
- `matrix.rkt` — 2D mutable matrix backed by a flat vector, with contracts. Uses `(row, col)` indexing.
- `ring-buffer.rkt` — Fixed-capacity circular buffer with contracts.
- `charnum.rkt` — Character/digit conversion utilities.
- `utils.rkt` — The `shadow-as` macro for rebinding variables through a conversion function.

**Day 08 uses a custom `#lang`:** `day08.rkt` is a reader module that parses `input08.rkt` as a DSL, with `day08-runtime.rkt` providing the runtime. This is Racket's language-oriented programming pattern.

**Style notes:**
- Complex numbers represent 2D positions/directions (see day01: `0+1i` for north)
- Contracts (`provide/contract-out`) on library module boundaries
- `match-define` and `match-let*` for destructuring
- Parameters (`make-parameter`/`parameterize`) for swapping between example and real input
