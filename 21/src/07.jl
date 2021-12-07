using Utils

using Underscores

inputfile = find_input(@__FILE__)
input = @_ read(inputfile, String) |> split(__, ",") |> map(parse(Int, _), __)

function part1(input)
    sort!(input)
    median = input[length(input) ÷ 2]
    sum(abs(median - pos) for pos in input)
end
@assert part1(input) == 349769

part1(input) |> println

triangular(n) = n*(n + 1)÷2

function part2(input)
    mean = sum(input) ÷ length(input)
    sum(triangular(abs(mean - pos)) for pos in input)
end
@assert part2(input) == 99540554

part2(input) |> println
