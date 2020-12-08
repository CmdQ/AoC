# Advent of Code 2020

## Purpose

This repo is to keep track of my [AoC 2020][aoc] [progress] while learning [Julia][] ([docs]).

## Thoughts

- Don't be [overzealous with types][overzealous].
- Julia lacks real discriminated unions. You can you `Union` types, but the compiler doesn't prevent you from adding more.

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

### 5

That was almost too easy. Julia's `parse` is capable of binary numbers, so after replacing letters you're done.
The whole splitting into rows and seats is nonsense.

### 06

- Used [Chain.jl][chain_jl] but appart from that it's really boring.

### 07

- Damn, in every new try I end up much too complicated!
- [LightGraphs.jl][lightgraphs_jl] seems popular, but how do I now if a node is already there?!?
- [Graphs.jl][graphs_jl] is modeled after Boost. Couldn't get it right either. Documentation needs more real examples.
- **If you don't make it complicated, it's easy.**
- Julia really is quite short, like it.

### 08

- File parsing is a nice example for using [Underscores.jl][underscores].
- Otherwise boring backtracking.



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
