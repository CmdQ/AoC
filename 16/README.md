# Advent of Code 2016 — Racket

## Days

### Day 01 — [No Time for a Taxicab](https://adventofcode.com/2016/day/1)
Walk a grid following L/R turn instructions; find final Manhattan distance and first revisited location.

- Concepts:
  - Complex numbers as 2D positions/directions, multiply by `±i` to rotate
- Racket:
  - `threading` (`~>`)
  - `for/fold` with multiple accumulators
  - Structs with `#:transparent`
  - Exception-as-control-flow (`raise`/`with-handlers`)
  - Sets

### Day 02 — [Bathroom Security](https://adventofcode.com/2016/day/2)
Navigate a keypad grid following UDLR instructions; first a square pad, then a diamond.

- Concepts:
  - Bounded grid movement, matrix as spatial lookup
- Racket:
  - `struct-copy`
  - `for/fold` with `#:result`
  - `matrix.rkt` module
  - `charnum.rkt` (`value->char`)

### Day 03 — [Squares With Three Sides](https://adventofcode.com/2016/day/3)
Count valid triangles from side lengths; part 2 reads columns instead of rows.

- Concepts:
  - Matrix transpose via `(apply map list ...)`
- Racket:
  - `match` destructuring
  - `split-at`
  - `lambda~>` (point-free threading)

### Day 04 — [Security Through Obscurity](https://adventofcode.com/2016/day/4)
Validate room codes by checksum (letter frequency); decrypt via Caesar cipher.

- Concepts:
  - Frequency histogram
  - Caesar cipher (modular arithmetic)
- Racket:
  - Mutable hash (`make-hash`, `hash-update!`)
  - Multi-key stable sort
  - `for/first` with `#:when`
  - Regex with `regexp-match`

### Day 05 — [How About a Nice Game of Chess?](https://adventofcode.com/2016/day/5)
Mine MD5 hashes with a "00000" prefix to build a password.

- Concepts:
  - MD5 hash mining
  - Lazy enumeration
- Racket:
  - **Streams** (`stream-cons`, `stream-map`, `stream-filter`, `stream-take`)
  - `#:eager` stream-cons
  - `openssl/md5`
  - Mutable strings (`string-set!`)

### Day 06 — [Signals and Noise](https://adventofcode.com/2016/day/6)
Recover a message from noisy repetitions using per-column histograms.

- Concepts:
  - Column-wise frequency analysis
- Racket:
  - Nested vectors
  - Higher-order functions as parameters (`>` vs `<` for most/least common)

### Day 07 — [Internet Protocol Version 7](https://adventofcode.com/2016/day/7)
Check if "IP addresses" support TLS (has ABBA outside brackets) and SSL (ABA/BAB across brackets).

- Concepts:
  - Regex backreferences
  - Palindrome substring detection
- Racket:
  - Curried function definitions `(define ((has-what? regex) str) ...)`
  - `regexp-replace*` with lambda
  - `regexp-match*` with `#:match-select`
  - `set!` in replace callback
  - `memf`

### Day 08 — [Two-Factor Authentication](https://adventofcode.com/2016/day/8)
Simulate a pixel screen with rect/rotate operations to display a code.

- Concepts:
  - 2D matrix rotation (row/column circular shift)
- Racket:
  - **Custom `#lang`** — `day08.rkt` is a reader module (`read-syntax`/`provide`), `day08-runtime.rkt` provides `#%module-begin` override
  - Input file `input08.rkt` uses `#lang reader "day08.rkt"`
  - `matrix.rkt` for the screen
  - `in-indexed`

### Day 09 — [Explosives in Cyberspace](https://adventofcode.com/2016/day/9)
Decompress a format with `(NxM)` repeat markers; part 2 recurses into markers.

- Concepts:
  - Recursive decompression
  - Port-based character-at-a-time parsing
- Racket:
  - Input ports (`open-input-string`, `read-char`, `read-string`)
  - `call-with-input-file`
  - Curried solver `(define ((solve solver) ...) ...)`

### Day 10 — [Balance Bots](https://adventofcode.com/2016/day/10)
Simulate bots passing chips to each other by low/high rules; find which bot compares specific values.

- Concepts:
  - Agent simulation
  - Event-driven processing
- Racket:
  - `struct/contract`
  - `match-lambda`
  - `shadow-as` macro (from `utils.rkt`)
  - Thunks for deferred mutation
  - `for-each` on `match-lambda`

### Day 11 — [Radioisotope Thermoelectric Generators](https://adventofcode.com/2016/day/11)
Move generators and microchips between floors (no unshielded chip next to foreign generator). Minimum moves via BFS.

- Concepts:
  - BFS on state space
  - Bit-packing state into integers
  - State pruning
- Racket:
  - `racket/treelist` (functional treelist for BFS queue)
  - `bitwise-ior`/`arithmetic-shift`
  - `mutable-set` for visited states
  - `parameterize` for part 2's larger state
  - `vector-set/copy`

### Day 12 — [Leonardo's Monorail](https://adventofcode.com/2016/day/12)
Simulate an assembunny computer (cpy/inc/dec/jnz instructions).

- Concepts:
  - Simple VM / interpreter
- Racket:
  - **Custom `#lang`** (second one) — `day12.rkt` is the reader, `day12-runtime.rkt` the runtime with `#%module-begin` override
  - Immutable hash as register file
  - `define/contract`
  - Dispatch table via `hasheq`

### Day 13 — [A Maze of Twisty Little Cubicles](https://adventofcode.com/2016/day/13)
Navigate a procedurally generated maze (bit-count parity); shortest path and reachability count.

- Concepts:
  - Dijkstra's algorithm
  - Procedural maze generation (bit counting)
- Racket:
  - `data/priority-queue`
  - `make-parameter`/`parameterize` for swapping example vs real input
  - `2htdp/image` visualization (`overlay`, `rectangle`, `circle`)
  - `in-drracket?` (`utils.rkt`) to suppress visualization when run from CLI

### Day 14 — [One-Time Pad](https://adventofcode.com/2016/day/14)
Find one-time pad keys by mining MD5 hashes for triple/quintuple character runs. Part 2 uses key stretching (2016 extra MD5 rounds).

- Concepts:
  - MD5 hash mining with key stretching
  - Sliding window confirmation (triple → quintuple within 1000 hashes)
  - Confirmations arrive out of order; must sort by index before selecting 64th key
- Racket:
  - **Streams** (lazy hash sequence)
  - `file/md5` — accepts `bytes?` directly, no port needed; stays in bytes throughout stretch loop
  - `and~>` for short-circuiting threading on `#f`
  - `filter-map` + `match-lambda` for combined filter/transform
  - `cond` with `=>` to bind and use test result in one clause
  - `quote` symbols (`'done`) as type tags to distinguish confirmed vs unconfirmed candidates
  - `byte-regexp` / `make-bytes` for bytes-native regex matching

## Project Infrastructure

### `run.rkt` — Benchmark runner
Optionally precompile first to reduce loading time:
```
raco make day*.rkt ring-buffer.rkt utils.rkt matrix.rkt charnum.rkt
```
Run all days or a specific day:
```
racket run.rkt        # benchmark all days
racket run.rkt 14     # run day 14 only
```
- Reports module loading time separately from execution time
- Falls back to `inputNN.rkt` for custom `#lang` days (08, 12) that have no `module+ main`
- Uses `find-system-path 'run-file` to locate day files relative to the script, not CWD
- `dynamic-require` with `(submod f main)` for submodule execution

### `utils.rkt` — Shared utilities
- `shadow-as` — macro to apply a transform function to multiple bindings in one expression
- `in-drracket?` — detects DrRacket vs CLI via `find-system-path 'exec-file`

### `ring-buffer.rkt` — Mutable ring buffer
Fixed-capacity circular buffer with `make-do-sequence` / `initiate-sequence` for `for` loop integration.

### Convention: `module+ main` and `module+ test`
Every day file has:
- `module+ test` — `rackunit` checks including example inputs and real answers
- `module+ main` — prints answers with `printf`; runs only when the file is executed directly or via `run.rkt`

## Quick Concept Index

| Concept | Days |
|---|---|
| Streams (lazy sequences) | 05, 14 |
| Custom `#lang` / reader macros | 08, 12 |
| `threading` / `~>` / `lambda~>` | 01, 02, 03, 04, 05, 07, 10, 11, 13, 14 |
| `matrix.rkt` (2D grid) | 02, 08, 13 |
| Complex number geometry | 01 |
| Regex (`regexp-match`, backrefs, `byte-regexp`) | 04, 07, 10, 11, 12, 14 |
| BFS / Dijkstra | 11, 13 |
| `for/fold` with accumulators | 01, 02, 03, 06 |
| Hash tables (mutable / immutable) | 04, 10, 12, 13 |
| Contracts (`contract-out`, `struct/contract`) | 10, 12 |
| Port-based I/O (`read-char`) | 09 |
| `parameterize` / `make-parameter` | 13, 14 |
| `match` / `match-lambda` / `match-define` | 03, 04, 10, 11, 13, 14 |
| Bit manipulation | 11, 13 |
| `2htdp/image` visualization | 13 |
| Curried definitions | 07, 09 |
| `shadow-as` macro (`utils.rkt`) | 04, 08, 10, 12 |
| `in-drracket?` (`utils.rkt`) | 13 |
| `treelist` (functional sequence) | 11 |
| Sets (`mutable-set`) | 01, 11 |
| `struct-copy` | 02 |
