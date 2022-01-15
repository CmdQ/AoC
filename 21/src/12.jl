using ProblemParser
using Utils

using Bijections
using Chain
using FunctionalCollections
using Graphs

const file = find_input(@__FILE__)
const input = parse(Lines(Split('-', Map(Symbol))), slurp(file))
const node2num = @chain input begin
    Iterators.flatten
    unique
    enumerate
    map(reverse, _)
    Dict
    Bijection
end

function make_graph(input)
    g = Graph(length(node2num))
    for (a,b) in input
        add_edge!(g, node2num[a], node2num[b])
    end
    g
end

smallcave(name::Symbol) = @chain name String _[1] islowercase

smallcave(num::Int) = node2num(num) |> smallcave

part1(g::Graph) = part1(g, node2num[:start])

part1(input) = @chain input make_graph part1

function part1(g::Graph, cur::Integer, visited=PersistentSet())
    current::Symbol = node2num(cur)
    current == :end && return 1
    withme = conj(visited, cur)
    paths = 0
    for n in neighbors(g, cur)
        (n in visited && (!smallcave(current) || smallcave(n))) && continue
        paths += part1(g, n, withme)
    end
    paths
end

assertequal(part1(input), 3779)

part2(g::Graph) = part2(g, node2num[:start], 1)

part2(input) = @chain input make_graph part2

function part2(g::Graph, cur::Integer, extra, visited=PersistentSet())
    current::Symbol = node2num(cur)
    current == :end && return 1
    withme = conj(visited, cur)
    paths = 0
    for n in neighbors(g, cur)
        if n ∉ visited || smallcave(current) && !smallcave(n)
            paths += part2(g, n, extra, withme)
        elseif extra > 0 && node2num(n) != :start && smallcave(n)
            paths += part2(g, n, extra - 1, withme)
        end
    end
    paths
end

assertequal(part2(input), 96988)
