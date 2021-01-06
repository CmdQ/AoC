# Advent of Code 2020

## Purpose

This repo is to keep track of my [AoC 2020][aoc] [progress] while learning [Julia][] ([docs]).

## Thoughts

- Don't be [overzealous with types](https://stackoverflow.com/a/56430371/581002).
- Julia lacks real discriminated unions. You can you `Union` types, but the compiler doesn't prevent you from adding more.
- [Code optimisation in Julia](https://techytok.com/code-optimisation-in-julia/)
- Tuple destructuring is kind of [strange](https://github.com/JuliaLang/julia/pull/23337]).
- How to write [iterators](https://julialang.org/blog/2018/07/iterators-in-julia-0.7/)
- An article about different [debuggers](https://julialang.org/blog/2019/03/debuggers/)
- I need to try [Revise](https://github.com/timholy/Revise.jl)
- [Composable multi-threaded parallelism in Julia](https://julialang.org/blog/2019/07/multithreading/)

## Post-event thoughts

- I could have used [Transducers](https://github.com/JuliaFolds/Transducers.jl).
- Not needed, but an [interesting take on AoS/SoA](https://github.com/JuliaArrays/StructArrays..jl)
- [TypedTables](https://github.com/JuliaData/TypedTables.jl) seem similar to Pandas.
- I should have used [SplitApplyCombine](https://github.com/JuliaData/SplitApplyCombine.jl) for that grouping problem I had.
- Maybe [AcceleratedArrays indices](https://github.com/andyferris/AcceleratedArrays.jl) would have helped in finding stuff in arrays.
- There are [IterTools](https://github.com/JuliaCollections/IterTools.jl) after all ([docs](https://juliacollections.github.io/IterTools.jl/latest/)).
- Easier definition of structs and parameter unpacking with [Parameters.jl](https://github.com/mauro3/Parameters.jl).
- Setters for immutable structs with [lenses](https://github.com/jw3126/Setfield.jl).
- There would have been [a combinatorics library](https://github.com/JuliaMath/Combinatorics.jl).
- [Modular arithmetic](https://github.com/scheinerman/Mods.jl) include CRT would have been available.
- Julia has [powermod](https://docs.julialang.org/en/v1/base/math/#Base.powermod).

Somebody else solved it using Julia and [blogged](https://blog.kdheepak.com/advent-of-code-2020-retrospective.html) about it.

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

### 6

- Used [Chain.jl][chain_jl] but appart from that it's really boring.

### 7

- Damn, in every new try I end up much too complicated!
- [LightGraphs.jl][lightgraphs_jl] seems popular, but how do I know if a node is already there?!?
- [Graphs.jl][graphs_jl] is modeled after Boost. Couldn't get it right either. Documentation needs more real examples.
- **If you don't make it complicated, it's easy.**
- Julia really is quite short, like it.

### 8

- File parsing is a nice example for using [Underscores.jl][underscores].
- Otherwise boring backtracking.

### 9

- [SubArrays][] are helpful here.

### 10

- For a very long time, my problem was that I [forgot to include the source port][reddit10] (0).
- Then with the help of a hash cache it gets super quick.
- [x] How do you write a [general `memoize` function in Julia? How to annotate Functions? Just with `::Function`.

### 11

- [`fill`][fill] with array assignment can be used nicely for boundary conditions.

### 12

- The computation is a simple summation via `foldl`. All the rest of the logic is in [operator][] [overloading][].

### 13

- All the time the wrong answer because `[17,missing,13,19]` needs to be `[(17, 17), (13, 11), (19, 16)]` and not `[(17, 0), (13, 2), (19, 3)]`.
- [Chinese Remainder Theorem][crt] put to good use.
- Intermediate steps were too big for `Int64`, nice that `Int128` is readily available. Pairwise parallel application with sorted moduli instead of `reduce` might have stayed within `Int64`.
- [SaferIntegers][saferintegers_jl] would have helped catching that earlier. Julia [wraps around][overflows] silently, but at least it is defined behaviour.

### 15

- Again, [dict][] is your friend.

### 16

- That was *not* fun and definitely had the most rewrites.

### 17

- [ ] Variable number of dimensions/loops could again be done with a macro.

### 18

- I knew you needed two Stacks. That one of them is reversed took a long time.
- Also making subexpressions while tokenizing spoils the [shunting yard][shunting] fun.

### 19

- [Multiple dispatch][dispatch] is awesome.

### 20

- This takes the longest so far because of missing types/type instability—Julia can't perform then.
- [ ] Could not figure out how to satisfy [`@code_warntype`][warntype].
- [x] As a way out: candidate for [threading][]? Didn't get faster.

### 21

- Loops made me go crazy again. Finally decided to get a [persistent data structure library][functional_ds] which makes thinking recursively a lot easier.
- [x] Another possibility for parallel code? Nope, `@threads` doesn't like something.

### 23

- Finally came around to implementing [non-standard string literals][strings]—nice.
- First solutions with arrays or linked list weren't finished after hours.
- Then I had the diea of a single array (index maps to slot content) and it takes a second.

### 24

- Nothing interesting except how to get hexagonal indexing right. Theoretically I could make it with half the memory.

### 25

- Very quickly solved thanks to the even exponent trick.

[aoc]: https://adventofcode.com/
[chain_jl]: https://github.com/jkrumbiegel/Chain.jl
[crt]: https://en.wikipedia.org/wiki/Chinese_remainder_theorem
[dict]: https://docs.julialang.org/en/v1/base/collections/#Base.Dict
[dispatch]: https://docs.julialang.org/en/v1/manual/methods/
[docs]: https://docs.julialang.org/en/v1/
[fill]: https://docs.julialang.org/en/v1/base/arrays/#Base.fill
[foldl]: https://docs.julialang.org/en/v1/base/collections/#Base.foldl-Tuple{Any,Any}
[functional_ds]: https://github.com/JuliaCollections/FunctionalCollections.jl
[graphs_jl]: https://graphsjl-docs.readthedocs.io/en/latest/
[heisenbug4]: https://stackoverflow.com/questions/65140849/
[ImmutableDict]: https://docs.julialang.org/en/v1/base/collections/#Base.ImmutableDict
[julia]: https://julialang.org/
[lightgraphs_jl]: https://github.com/JuliaGraphs/LightGraphs.jl
[notco]: https://groups.google.com/g/julia-dev/c/POP6YXCnP-k/m/vTxLngw_jSIJ
[operator]: https://docs.julialang.org/en/v1/devdocs/ast/#Operators
[overflows]: https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Overflow-behavior
[overloading]: https://docs.julialang.org/en/v1/manual/methods/
[progress]: https://adventofcode.com/2020
[reddit10]: https://www.reddit.com/r/adventofcode/comments/kd0ksw/2020_day_10_part_2_always_the_same_wrong_example/
[reduce]: https://docs.julialang.org/en/v1/base/collections/#Base.reduce-Tuple{Any,Any}
[saferintegers_jl]: https://github.com/JeffreySarnoff/SaferIntegers.jl
[shunting]: https://en.wikipedia.org/wiki/Shunting-yard_algorithm
[strings]: https://docs.julialang.org/en/v1/manual/metaprogramming/#Non-Standard-String-Literals
[subarrays]: https://docs.julialang.org/en/v1/devdocs/subarrays/
[tco]: https://en.wikipedia.org/wiki/Tail_call
[threading]: https://docs.julialang.org/en/v1/manual/parallel-computing/
[underscores]: https://c42f.github.io/Underscores.jl/stable/
[warntype]: https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype
