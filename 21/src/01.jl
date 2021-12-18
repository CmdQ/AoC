using ProblemParser
using Utils

using Chain
import IterTools

file = find_input(@__FILE__)
input = @chain file slurp parse(Lines(Convert()), _)

function part1(input)
    sum((@view input[2:end]) .> (@view input[1:end-1]))
end
assertequal(part1(input), 1298)

function part2(input)
    @chain input begin
        IterTools.partition(3, 1)
        map(sum, _)
        part1
    end
end
assertequal(part2(input), 1248)
