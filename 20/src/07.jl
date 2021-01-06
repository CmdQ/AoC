using Underscores
using Utils

const Edge = Tuple{Int,String}
const Edges = Array{Edge,1}

function parse_file(f)
    graph = Dict{String,Edges}()
    for line in eachline(f)
        outer, inner = split(line[1:end-1], " bags contain ")
        @assert !haskey(graph, outer)
        edges = Edges()
        if !occursin("no other", inner)
            for target in split(inner[1:end-1], ", ")
                m = match(r"(\d+) (\w+ \w+)", target)
                push!(edges, (parse(Int, m[1]), m[2]))
            end
        end
        graph[outer] = edges
    end
    graph
end

function load()
    open(joinpath(@__DIR__, "07_color-bags.txt"), "r") do f
        parse_file(f)
    end
end

bags = load()
const mine = "shiny gold"

function find_path(bags, color, what)
    color == what && return true

    for edge in bags[color]
         if find_path(bags, edge[2], what)
            return true
         end
    end

    return false
end

function ex1(bags)
    count(@_ filter(_ != mine, keys(bags))) do rule
        find_path(bags, rule, mine)
    end
end

function ex2(bags, color)
    edges = bags[color]
    isempty(edges) && return 1

    1 + sum(edges) do (count, inner)
        count * ex2(bags, inner)
    end
end

ex2(bags) = ex2(bags, mine) - 1

println("At least one $mine bag: ", ex1(bags))
println("Bags required inside $mine: ", ex2(bags))














using Test

@testset "Handy Haversacks" begin
    input = """
        light red bags contain 1 bright white bag, 2 muted yellow bags.
        dark orange bags contain 3 bright white bags, 4 muted yellow bags.
        bright white bags contain 1 shiny gold bag.
        muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
        shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
        dark olive bags contain 3 faded blue bags, 4 dotted black bags.
        vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
        faded blue bags contain no other bags.
        dotted black bags contain no other bags.
        """
    example = parse_file(IOBuffer(input))

    @testset "example 1" begin
        @test length(example) == 9
        @test ex1(example) == 4
    end

    @testset "example 2" begin
        @test ex2(example) == 32

        input2 = """
            shiny gold bags contain 2 dark red bags.
            dark red bags contain 2 dark orange bags.
            dark orange bags contain 2 dark yellow bags.
            dark yellow bags contain 2 dark green bags.
            dark green bags contain 2 dark blue bags.
            dark blue bags contain 2 dark violet bags.
            dark violet bags contain no other bags.
            """
        example2 = parse_file(IOBuffer(input2))

        @test ex2(example2) == 126
    end

    @testset "results" begin
        @test ex1(bags) == 229
        @test ex2(bags) == 6683
    end
end