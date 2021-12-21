using ProblemParser
using Utils

using Underscores

const file = find_input(@__FILE__)
const input = parse(Split(",", Convert(Int8)), slurp(file))

function solve(input, days)
    ages = zeros(Int, 9) |> zerobased
    for age in input
        ages[age] += 1
    end
    for _ in 1:days
        ages = circshift(ages, -1)
        ages[6] += ages[8]
    end
    sum(ages)
end

assertequal(solve(input, 80), 350917)
assertequal(solve(input, 256), 1592918715629)
