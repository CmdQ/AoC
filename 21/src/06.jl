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
        ages = circshift(ages, -1)
        ages[6] += ages[8]
    end
    sum(ages)
end

assertequal(solve(input, 80), 350917)
assertequal(solve(input, 256), 1592918715629)
