using Utils

using Chain
import IterTools

inputfile = find_input(@__FILE__)
input = @chain inputfile slurp per_line_parse

function one(input)
    sum((@view input[2:end]) .> (@view input[1:end-1]))
end
@assert one(input) == 1298

function two(input)
    @chain input begin
        IterTools.partition(3, 1)
        map(sum, _)
        one
    end
end
@assert two(input) == 1248

for f in [one, two]
    @chain input f println
end
