using ProblemParser
using Utils

using Chain
import IterTools

struct Off0Matrix
    rules::Vector{Bool}
    parent::Matrix{Bool}
    at_infinity::Bool
end
Off0Matrix(rules, matrix) = Off0Matrix(rules, matrix, false)

file = find_input(@__FILE__)
tobool = Map(e -> e == '#')
input = Off0Matrix(parse(FirstRest(Blocks(), tobool, Rectangular(tobool)), slurp(file))...)

Base.size(matrix::Off0Matrix) = size(matrix.parent)

Base.checkbounds(::Type{Bool}, matrix::Off0Matrix, ci::CartesianIndex{2}) = checkbounds(Bool, matrix.parent, ci)

function Base.getindex(matrix::Off0Matrix, inds)
    checkbounds(Bool, matrix, inds) ? getindex(matrix.parent, inds) : matrix.at_infinity
end

numfrom3x3(matrix::Off0Matrix, num::Int) = matrix.rules[num + 1]
numfrom3x3(matrix::Off0Matrix, bits::AbstractArray{Bool}) = numfrom3x3(matrix, foldl((l,r) -> (l << 1) | Int(r), bits; init=0))

neighbors = CartesianIndices((-1:1, -1:1)) |> permutedims

function Base.iterate(matrix::Off0Matrix, state=matrix)
    border = 1
    output = Matrix{Bool}(undef, (size(state) .+ 2border)...)
    for ci in CartesianIndices(output)
        output[ci] = @chain ci begin
            [state[i - CartesianIndex(1,1)] for i in (neighbors .+ [_])]
            numfrom3x3(state, _)
        end
    end
    # Also calculate new value at infinity.
    output, Off0Matrix(state.rules, output, numfrom3x3(state, Iterators.repeated(state.at_infinity, 9) |> collect))
end

Base.IteratorSize(::Off0Matrix) = Base.IsInfinite()

solve(input, n) = IterTools.nth(input, n) |> count

part1 = Base.Fix2(solve, 2)

assertequal(part1(input), 5400)

part2 = Base.Fix2(solve, 50)

assertequal(part2(input), 18989)
