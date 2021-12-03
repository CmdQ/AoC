using Utils

using Lazy
using Underscores

inputfile = find_input(@__FILE__)
lines = @> inputfile slurp per_line(false)
matrix = falses(length(lines), length(lines[1]))
for (i, num) in enumerate(lines)
    @_ matrix[i,:] = map(parse(Bool, _), collect(num))
end
matrix

function one(matrix)
    len = size(matrix, 1)
    gamma =
        @_ [sum(matrix[:,r]) > len ÷ 2 for r in axes(matrix, 2)] |>
        map(Char(_ + '0'), __) |>
        String |>
        parse(Int, __; base=2)
    epsilon = gamma ⊻ (2^size(matrix, 2) - 1)
    gamma * epsilon
end
@assert one(matrix) == 693486

function sortdown(digit, lines)
    pos = firstindex(lines)
    while length(lines) > 1
        @_ sort!(lines; by=_[pos])
        first1 = @_ findfirst(_[pos] == '1', lines)
        num0 = first1 - 1
        half = length(lines) ÷ 2
        if digit == 0 && num0 <= half || digit == 1 && num0 > half
            lines = lines[begin:num0]
        else
            lines = lines[first1:end]
        end
        pos += 1
    end
    parse(Int, lines[begin]; base=2)
end

function two(lines)
    oxygen = sortdown(1, copy(lines))
    co2 = sortdown(0, copy(lines))
    oxygen * co2
end
@assert two(lines) == 3379326

println(one(matrix))
println(two(lines))