using Utils

using Chain
import IterTools

inputfile = find_input(@__FILE__)
input = @chain inputfile slurp per_line_parse

function part1(input)
    sum((@view input[2:end]) .> (@view input[1:end-1]))
end
@assert part1(input) == 1298

function part2(input)
    @chain input begin
        IterTools.partition(3, 1)
        map(sum, _)
        part1
    end
end
@assert part2(input) == 1248

for f in [part1, part2]
    @chain input f println
end
