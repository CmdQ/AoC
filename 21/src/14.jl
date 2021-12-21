using ProblemParser
using Utils

using DataStructures
using Dictionaries
using SplitApplyCombine

import IterTools

const file = find_input(@__FILE__)
const input = parse(FirstRest(Blocks(),
        nothing,
        LineMappings(Split(" -> "), Apply(Tuple), Apply(c -> c[begin])),
    ), slurp(file))

function solve(input, rounds)
    line = input[1]
    pairs = DefaultDict{Tuple{Char,Char},Int}(0)
    for tup in IterTools.partition(line, 2, 1)
        pairs[tup] = pairs[tup] = pairs[tup] + 1
    end
    for _ in 1:rounds
        next = DefaultDict{Tuple{Char,Char},Int}(0)
        for (pair, count) in pairs
            middle = input[2][pair]
            tup = pair[1], middle
            next[tup] = next[tup] + count
            tup = middle, pair[2]
            next[tup] = next[tup] + count
        end
        pairs = next
    end
    letters = groupsum(tup -> tup[1][1], tup -> tup[2], pairs)
    set!(letters, line[end], get(letters, line[end], 0) + 1)
    mi, ma = extrema(letters)
    ma - mi
end

assertequal(solve(input, 10), 3048)

assertequal(solve(input, 40), 3288891573057)
