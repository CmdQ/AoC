using Utils

using Lazy
using Underscores

inputfile = find_input(@__FILE__)
input = @> inputfile slurp per_line(false)
@assert @_ map(length(_), input) |> Set |> length == 1

function part1(input)
    matrix = @_ input |>
        map(map(==('1'), collect(_)), __) |>
        reduce(hcat, __) |>
        transpose
    len = size(matrix, 1)

    gamma =
        @_ [sum(matrix[:,r]) > len ÷ 2 for r in axes(matrix, 2)] |>
        map(curry(+, '0'), __) |>
        String |>
        parse(Int, __; base=2)
    epsilon = gamma ⊻ (2^size(matrix, 2) - 1)
    gamma * epsilon
end
assertequal(part1(input), 693486)

function sortdown(digit1, input)
    input = sort(input)
    pos = 1
    while length(input) > 1
        first1 = @_ findfirst(_[pos] == '1', input)
        num0 = first1 - 1
        if digit1 ⊻ (num0 <= length(input) ÷ 2)
            input = input[begin:num0]
        else
            input = input[first1:end]
        end
        pos += 1
    end
    parse(Int, input[begin]; base=2)
end

function part2(input)
    oxygen = sortdown(true, input)
    co2 = sortdown(false, input)
    oxygen * co2
end
assertequal(part2(input), 3379326)
