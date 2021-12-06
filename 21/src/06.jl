using Utils

using Underscores

inputfile = find_input(@__FILE__)
input = @_ read(inputfile, String) |> split(__, ",") |> map(parse(Int, _), __)

function solve(input, days)
    ages = zeros(Int, 9) |> zerobased
    for age in input
        ages[age] += 1
    end
    for _ in 1:days
        reproducer = ages[0]
        for a in 1:8
            ages[a-1] = ages[a]
        end
        ages[6] += reproducer
        ages[8] = reproducer
    end
    sum(ages)
end
solve(input, 80) |> println
solve(input, 256) |> println
