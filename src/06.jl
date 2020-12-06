using Utils

function parse(f, combiner)
    map(block -> reduce(combiner, map(Set, split(block))), split(f))
end

function load(combiner)
    open("$(@__DIR__)/../inputs/customs-declarations.txt", "r") do f
        parse(f, combiner)
    end
end

function sumcount(sets)
    sum(s -> length(s), sets)
end

println("Misunderstood sum of counts is: ", sumcount(load(union)))
println("Correct       sum of counts is: ", sumcount(load(intersect)))




using Test

@testset "" begin
    input = """
    abc

    a
    b
    c

    ab
    ac

    a
    a
    a
    a

    b
    """


    @testset "example 1" begin
        example = parse(IOBuffer(input), union)

        @test length(example) == 5
        @test example[1] == example[2] == example[3]
        @test sumcount(example) == 11
    end

    @testset "example 2" begin
        example = parse(IOBuffer(input), intersect)

        @test length(example) == 5
        @test sumcount(example) == 6
    end

    @testset "results" begin
    end
end