using Utils
using Chain

function parse_file(f, combiner)
    map(split(f)) do block
        @chain block begin
            split
            map(Set, _)
            reduce(combiner, _)
        end
    end
end

function load(combiner)
    open(joinpath(@__DIR__, "06_customs-declarations.txt"), "r") do f
        parse_file(f, combiner)
    end
end

function sumcount(sets)
    sum(length, sets)
end

println("Misunderstood sum of counts is: ", union |> load |> sumcount)
println("Correct       sum of counts is: ", intersect |> load |> sumcount)







using Test

@testset "Custom Customs" begin
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
        example = parse_file(IOBuffer(input), union)

        @test length(example) == 5
        @test example[1] == example[2] == example[3]
        @test sumcount(example) == 11
    end

    @testset "example 2" begin
        example = parse_file(IOBuffer(input), intersect)

        @test length(example) == 5
        @test sumcount(example) == 6
    end

    @testset "results" begin
        @test union |> load |> sumcount == 6947
        @test intersect |> load |> sumcount == 3398
    end
end