using ProblemParser
using Utils

using Chain
using Underscores

file = find_input(@__FILE__)
input = parse(Lines(Split(" | ", Split())), slurp(file))

function part1(input)
    @chain input begin
        map(tup -> tup[2], _)
        Iterators.flatten
        count(code -> length(code) in [2,3,4,7], _)
    end
end

assertequal(part1(input), 272)

function decode((numbers, codes))
    digits::Vector{Set{Char}} = map(Set, numbers)
    mapping = Vector(undef, 10) |> zerobased
    for (len,num) in [(2,1),(3,7),(4,4),(7,8)]
        mapping[num] = digits[findfirst(s -> length(s) == len, digits)]
    end
    fives::Vector{Set{Char}}, sixes::Vector{Set{Char}} = [filter(s -> length(s) == i, digits) for i in 5:6]
    six::Int = findfirst(sixes) do s
        length(setdiff(s, mapping[1])) == 6 - 1
    end
    mapping[6] = popat!(sixes, six)
    upperright::Set{Char} = setdiff(mapping[8], mapping[6])
    three::Int = findfirst(fives) do s
        length(setdiff(s, mapping[1])) == 5 - 2
    end
    mapping[3] = popat!(fives, three)
    two::Int = findfirst(fives) do s
        length(setdiff(s, upperright)) == 5 - 1
    end
    mapping[2] = popat!(fives, two)
    mapping[5] = popat!(fives, 1)
    nine::Int = findfirst(sixes) do s
        length(setdiff(s, mapping[4])) == 6 - 4
    end
    mapping[9] = popat!(sixes, nine)
    mapping[0] = popat!(sixes, 1)

    re = 0
    for code in codes
        re = re * 10 + findfirst(==(Set(code)), mapping)
    end
    re
end

function part2(input)
    map(code -> decode(code), input) |> sum
end

assertequal(part2(input), 1007675)
