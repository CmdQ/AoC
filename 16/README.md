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

### Day 15 — [Timing is Everything](https://adventofcode.com/2016/day/15)
Drop a capsule through rotating discs; find the first time all disc slots align.

- Concepts:
  - Chinese Remainder Theorem (CRT)
  - Extended Euclidean Algorithm (Bézout coefficients)
  - Modular inverse
- Racket:
  - `define/match` (from `racket/match`)
  - Multiple return values with `values` / `match-define-values`
  - Cons pairs as lightweight key-value data

### Day 16 — [Dragon Checksum](https://adventofcode.com/2016/day/16)
Generate data via the dragon curve, then checksum by pairwise comparison until odd length. Part 2 scales to 35M bits.

- Concepts:
  - Dragon curve (modified: reverse + flip)
  - SWAR (SIMD Within A Register) — bulk bit operations on bignums
  - O(log n) bit compression and bit reversal using alternating masks
  - Pad-to-power-of-2 trick for arbitrary-width SWAR reversal
- Racket:
  - `nint.rkt` module — fixed-width integer struct with `nint-mask`, `logical-shift`
  - Arbitrary-precision integer bit manipulation (`bitwise-xor`, `bitwise-and`, `arithmetic-shift`)
  - `bitwise-not` pitfall with bignums (infinite sign extension) — use XOR with mask instead
  - `make-flat-contract` for custom contracts
  - `define/match` with `#:when` guards

### Day 17 — [Two Steps Forward](https://adventofcode.com/2016/day/17)
Navigate a 4×4 vault where doors are determined by MD5 hashes of the path so far. Part 1: shortest path (BFS). Part 2: longest path (DFS).

- Concepts:
  - BFS for shortest path, DFS for longest path
  - MD5-determined dynamic maze
- Racket:
  - `data/queue` with `enqueue!`/`enqueue-front!` to switch BFS↔DFS
  - `filter-map` + `match-lambda` over a direction table
  - `curry` / `curryr` for partial application (`enqueuer`, `solve1`/`solve2`)
  - `file/md5` on `bytes?`
  - `bytes-append` / `subbytes` for path accumulation
  - `define/contract` with `(or/c 'DFS 'BFS)` symbol contracts

### Day 18 — [Like a Rogue](https://adventofcode.com/2016/day/18)
Generate trap rows where each tile is XOR of its upper-left and upper-right neighbors; count safe tiles.

- Concepts:
  - Cellular automaton (Rule 90 / XOR of neighbors)
  - Bit-packed rows for O(1) step computation
- Racket:
  - `nint.rkt` for fixed-width bit manipulation
  - `for/fold` with `#:result` for running count without accumulating rows
  - Dual dispatch via `define/match` — string and nint implementations

### Day 19 — [An Elephant Named Joseph](https://adventofcode.com/2016/day/19)
Josephus problem: elves in a circle steal presents. Part 1: steal from neighbor. Part 2: steal from across.

- Concepts:
  - Josephus problem
  - Circular elimination
- Racket:
  - `data/queue` as circular buffer (dequeue → decide → re-enqueue)

### Day 20 — [Firewall Rules](https://adventofcode.com/2016/day/20)
Find the lowest unblocked IP and count all unblocked IPs given a list of blocked ranges. Uses an augmented interval BST with subtree max values.

- Concepts:
  - Augmented interval tree (BST keyed by `lo`, each node stores subtree max `hi`)
  - In-order traversal with running ceiling to detect gaps
  - Escape continuation for early exit (part 1)
- Racket:
  - `define-match-expander` for `N` (node), `L` (leaf), `P` (payload) — flattens nested struct patterns
  - `let/ec` for early-exit in-order traversal
  - Named `let` + `define-values` for multi-value accumulation (part 2)
  - `case-lambda` for multi-arity smart constructor
  - Curried definition `((flip f) a b)` added to `utils.rkt`
  - `values` / `define-values` for threading ceiling through recursion

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
- `must-be` — inline assertion that returns the value if it matches expected, errors otherwise. Used in `module+ main` to both print and verify answers. Supports `'TODO` (warning) and `#f` (skip check).
- `bit-count` — count set bits in an integer
- `string-md5` — MD5 of a string via `openssl/md5`
- `flip` — higher-order function returning a version of `f` with its two arguments swapped; `((flip f) a b)` = `(f b a)`

### `nint.rkt` — Fixed-width integers
Struct pairing an integer with an explicit bit width (since `integer-length` drops leading zeros). Provides:
- `make-nint` — infer width or specify explicitly
- `nint-mask` — all-ones mask for the width (accepts `nint` or plain integer)
- `logical-shift` — arithmetic shift with masking to width (no sign extension on right shift)

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
| `threading` / `~>` / `lambda~>` | 01, 02, 03, 04, 05, 07, 10, 11, 13, 14, 17, 18, 20 |
| `matrix.rkt` (2D grid) | 02, 08, 13 |
| Complex number geometry | 01 |
| Regex (`regexp-match`, backrefs, `byte-regexp`) | 04, 07, 10, 11, 12, 14 |
| BFS / Dijkstra | 11, 13, 17 |
| `for/fold` with accumulators | 01, 02, 03, 06, 18 |
| Hash tables (mutable / immutable) | 04, 10, 12, 13 |
| Contracts (`contract-out`, `struct/contract`, `define/contract`) | 10, 12, 16, 17 |
| Port-based I/O (`read-char`) | 09 |
| `parameterize` / `make-parameter` | 13, 14 |
| `match` / `match-lambda` / `match-define` | 03, 04, 10, 11, 13, 14, 15, 16, 17, 18, 20 |
| Bit manipulation | 11, 13, 16, 18 |
| SWAR (bulk bignum bit ops) | 16 |
| `2htdp/image` visualization | 13 |
| Curried definitions | 07, 09, 17, 20 |
| `define-match-expander` | 20 |
| Escape continuations (`let/ec`) | 20 |
| `values` / `define-values` (multiple return) | 15, 20 |
| Augmented BST / interval tree | 20 |
| `shadow-as` macro (`utils.rkt`) | 04, 08, 10, 12 |
| `in-drracket?` (`utils.rkt`) | 13 |
| `nint.rkt` (fixed-width integers) | 16, 18 |
| `treelist` (functional sequence) | 11 |
| `data/queue` | 11, 17, 19 |
| Sets (`mutable-set`) | 01, 11 |
| `struct-copy` | 02 |
| Modular arithmetic / CRT | 15 |
| MD5 hashing (`file/md5`) | 05, 14, 17 |
| `curry` / `curryr` (partial application) | 17 |
