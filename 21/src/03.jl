using Utils

using Lazy
using Underscores

inputfile = find_input(@__FILE__)
lines = @> inputfile slurp per_line(false)
@assert @_ map(length(_), lines) |> Set |> length == 1

function one(lines)
    matrix = @_ lines |>
        map(map(==('1'), collect(_)), __) |>
        reduce(hcat, __) |>
        transpose
    len = size(matrix, 1)

    gamma =
        @_ [sum(matrix[:,r]) > len ÷ 2 for r in axes(matrix, 2)] |>
        map(Char(_ + '0'), __) |>
        String |>
        parse(Int, __; base=2)
    epsilon = gamma ⊻ (2^size(matrix, 2) - 1)
    gamma * epsilon
end
@assert one(lines) == 693486

function sortdown(digit1, lines)
    lines = sort(lines)
    pos = 1
    while length(lines) > 1
        first1 = @_ findfirst(_[pos] == '1', lines)
        num0 = first1 - 1
        if digit1 ⊻ (num0 <= length(lines) ÷ 2)
            lines = lines[begin:num0]
        else
            lines = lines[first1:end]
        end
        pos += 1
    end
    parse(Int, lines[begin]; base=2)
end

function two(lines)
    oxygen = sortdown(true, lines)
    co2 = sortdown(false, lines)
    oxygen * co2
end
@assert two(lines) == 3379326

println(one(lines))
println(two(lines))