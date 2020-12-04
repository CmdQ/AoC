# Advent of Code 2020

## Purpose

This repo is to keep track of my [AoC 2020][aoc] [progress] while learning [Julia][] ([docs]).

## Thoughts

### 01

- [ ] Could the variable number of nested loops be an opportunity for macros?
- [x] The same could also be done with recursion. Does Julia do [TCO][]? No. :(

### 03

- `IOBuffer` easily passes a `String` where files are expected.

### 04

- [ ] Why does `const Mappings = Dict{String, String}` not work?
- [ ] Heisenbug?
- [ ] Loading with `reduce`/`foldl` and `ImmutableDict`


[aoc]: https://adventofcode.com/
[progress]: https://adventofcode.com/2020
[julia]: https://julialang.org/
[docs]: https://docs.julialang.org/en/v1/
[tco]: https://en.wikipedia.org/wiki/Tail_call