using ProblemParser
using Utils

import IterTools

file = find_input(@__FILE__)
input = parse(FirstRest(Blocks(),
        nothing,
        LineMappings(Split(" -> "), Apply(Tuple), Apply(c -> c[begin])),
    ), slurp(file))

function solve(input, rounds)
    line = input[1]
    pairs = Dict{Tuple{Char,Char},Int}()
    for tup in IterTools.partition(line, 2, 1)
        pairs[tup] = get(pairs, tup, 0) + 1
    end
    for _ in 1:rounds
        next = Dict{Tuple{Char,Char},Int}()
        for (pair, count) in pairs
            middle = input[2][pair]
            tup = pair[1], middle
            next[tup] = get(next, tup, 0) + count
            tup = middle, pair[2]
            next[tup] = get(next, tup, 0) + count
        end
        pairs = next
    end
    letters = Dict{Char, Int}()
    for ((a,_),count) in pairs
        letters[a] = get(letters, a, 0) + count
    end
    letters[line[end]] = get(letters, line[end], 0) + 1
    mi, ma = extrema(kv -> kv[2], letters)
    ma - mi
end

assertequal(solve(input, 10), 3048)

assertequal(solve(input, 40), 3288891573057)
