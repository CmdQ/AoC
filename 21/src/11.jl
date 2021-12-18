using ProblemParser
using Utils

using Chain

file = find_input(@__FILE__    )#,"example.txt")
input = parse(Rectangular(Convert(Int8)), slurp(file))

NEIGHBORS = CartesianIndices((-1:1, -1:1))

function flash(input, locations)
    length(locations) == 0 && return 0
    cascade = Set{CartesianIndex}()
    for loc in locations
        for neighbor in NEIGHBORS .+ [loc]
            input[neighbor] += 1
            if input[neighbor] == 10
                push!(cascade, neighbor)
            end
        end
    end
    input[begin,:] .= 0
    input[end,:] .= 0
    input[:,begin] .= 0
    input[:,end] .= 0
    return length(locations) + flash(input, cascade)
end

struct Aoc2111
    matrix::Matrix{Int8}
    inner::CartesianIndices
end
Aoc2111(input) = Aoc2111(input,
    CartesianIndices((firstindex(input, 1) + 1:lastindex(input, 2) + 1, firstindex(input, 1) + 1:lastindex(input, 2) + 1))
)

function Base.iterate(aoc::Aoc2111, state=boundaryconditions(aoc.matrix, convert(Int8, 0)))
    state[aoc.inner] .+= 1
    flashers = findall(>(9), state)
    flashes = flash(state, flashers)
    state[state .> 9] .= 0
    ((grid=view(state, aoc.inner), flashes=flashes), state)
end

Base.IteratorSize(::Aoc2111) = Base.IsInfinite()
Base.eltype(::Aoc2111) = @NamedTuple{grid::AbstractMatrix{Int8}, flashes::Int}

function part1(input, steps)
    @chain input begin
        Aoc2111
        Iterators.take(steps)
        map(tup -> tup.flashes, _)
        sum
    end
end

assertequal(part1(input, 100), 1608)

function part2(input)
    @chain input begin
        Aoc2111
        enumerate
        Iterators.filter(_) do (i,state)
            all(state.grid .== 0)
        end
        first
        first
    end
end

assertequal(part2(input), 214)
