using ProblemParser
using Utils

using Chain
using DataStructures
using StaticArrays

file = find_input(@__FILE__)
input = parse(Rectangular(Convert(Int8)), slurp(file))

const NSEW = SVector{4,CartesianIndex}(CartesianIndex(lr...) for lr in ((0,-1),(0,1),(-1,0),(1,0)))

function findmins(input)::BitMatrix
    extended = boundaryconditions(input, 10)
    center = keys(input) .+ CartesianIndex(1, 1)
    @chain NSEW begin
        map(ci -> input .< getindex(extended, center .+ ci), _)
        reduce((a,b) -> a .&& b, _)
    end
end

function part1(input)
    @chain input begin
        findmins
        input[_]
        _ .+ 1
        sum
    end
end

assertequal(part1(input), 530)

function fill_basins(input)
    extended = boundaryconditions(input, 10)
    seeds = findmins(extended)
    todo = findall(seeds)
    basins = DisjointSets(todo)
    handled = falses(size(extended))
    while length(todo) > 0
        current = pop!(todo)
        handled[current] && continue
        for neighbor in NSEW .+ [current]
            (handled[neighbor] || extended[neighbor] >= 9) && continue
            if extended[neighbor] > extended[current]
                union!(basins, current, push!(basins, neighbor))
                push!(todo, neighbor)
            end
        end
        handled[current] = true
    end
    basins
end

function part2(input)::Int
    roots = Dict()
    basins = fill_basins(input)
    for basin in unique(basins)
        root = find_root!(basins, basin)
        roots[root] = get(roots, root, 0) + 1
    end
    sizes = roots |> values |> collect
    len = length(sizes)
    partialsort(sizes, len-2:len) |> prod
end

assertequal(part2(input), 1019494)
