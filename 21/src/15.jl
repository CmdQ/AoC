using ProblemParser
using Utils

using Chain
using DataStructures
using Dictionaries
using StaticArrays

const file = find_input(@__FILE__)
const input = parse(Rectangular(Convert(Int8)), slurp(file))

const NSEW = SVector{4,CartesianIndex}(CartesianIndex(lr...) for lr in ((0,-1),(0,1),(-1,0),(1,0)))

function part1(input)::Int
    pq = @chain begin
        input
        size
        CartesianIndices
        zip(_, Iterators.repeated(Inf))
        PriorityQueue
    end
    pq[CartesianIndex(1,1)] = input[1,1]
    prev = Dictionary{CartesianIndex,CartesianIndex}()

    while !isempty(pq)
        u,dist = dequeue_pair!(pq)

        for v in intersect(NSEW .+ [u], keys(pq))
            alt = dist + input[v]
            if alt < pq[v]
                pq[v] = alt
                set!(prev, v, u)
            end
        end
    end
    risk::Int = 0
    backtrace = CartesianIndex(size(input))
    while backtrace != CartesianIndex(1,1)
        risk += input[backtrace]
        backtrace = prev[backtrace]
    end
    risk
end

assertequal(part1(input), 498)

function part2(input)
    repeat = 5
    extended = hvcat(repeat, [mod1.(input .+ (i + j), 9) for i=0:repeat - 1 for j=0:repeat - 1]...)
    part1(extended)
end

assertequal(part2(input), 2901)
