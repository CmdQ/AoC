# Advent of Code 2020

## Purpose

This repo is to keep track of my [AoC 2020][aoc] [progress] while learning [Julia][] ([docs]).

## Thoughts

- Don't be [overzealous with types][overzealous].

[overzealous]: https://stackoverflow.com/a/56430371/581002

### 1

- [x] Could the variable number of nested loops be an opportunity for macros?
- [x] The same could also be done with recursion. Does Julia do [TCO][]? [No][notco]. :(

### 3

- `IOBuffer` easily passes a `String` where files are expected.

### 4

- [x] Why does `const Mappings = Dict{String, String}` not work? It does [now](https://github.com/CmdQ/AoC2020/commit/e2c14ecce1fcd80a8872ccf5ce800d1537a1a867), no idea why.
- [ ] [Heisenbug?][heisenbug4]
- [ ] Loading with [`reduce`][reduce]/[`foldl`][foldl] and [`ImmutableDict`][ImmutableDict]

### 5

That was almost too easy. Julia's `parse` is capable of binary numbers, so after replacing letters you're done.
The whole splitting into rows and seats is nonsense.

#### Heisenbug

The working code uses this function:

```julia
function fd(s::String, fromto::UnitRange)::Bool
    parsed = tryparse(UInt, s)
    if isnothing(parsed)
        false
    else
        parsed in fromto
    end
end
```

When I had the version with exception, it only worked while debugging, but not otherwise.

```julia
function fd(s::String, fromto::UnitRange)::Bool
    try
        parse(UInt, s) in fromto
    catch ArgumentError
        false
    end
end
```



[aoc]: https://adventofcode.com/
[progress]: https://adventofcode.com/2020
[julia]: https://julialang.org/
[docs]: https://docs.julialang.org/en/v1/
[tco]: https://en.wikipedia.org/wiki/Tail_call
[heisenbug4]: https://stackoverflow.com/questions/65140849/
[notco]: https://groups.google.com/g/julia-dev/c/POP6YXCnP-k/m/vTxLngw_jSIJ
[reduce]: https://docs.julialang.org/en/v1/base/collections/#Base.reduce-Tuple{Any,Any}
[foldl]: https://docs.julialang.org/en/v1/base/collections/#Base.foldl-Tuple{Any,Any}
[ImmutableDict]: https://docs.julialang.org/en/v1/base/collections/#Base.ImmutableDict
