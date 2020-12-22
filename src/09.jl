using Underscores
using Utils

function parse_file(f)
    @_ map(parse(Int64, _), eachline(f))
end

function load()
    open(aoc"09_encrypted", "r") do f
        parse_file(f)
    end
end

function search_summands(target, candidates)
    for i in candidates, j in candidates
        if i + j == target
            return i, j
        end
    end
end

function ex1(code, lookback)
    for i in lookback+1:length(code)
        if isnothing(search_summands(code[i], view(code, i-lookback:i-1)))
            return code[i]
        end
    end
end

function ex2(code, nonsum)
    l = length(code)
    for i in eachindex(code)
        s = code[i]
        for j in i+1:l
            s += code[j]
            if s == nonsum
                mi, ma = extrema(view(code, i:j))
                return mi + ma
            elseif s > nonsum
                break
            end
        end
    end
end

code = load()

nonsum = ex1(code, 25)
println("The first number not a sum is: ", nonsum)
println("The code breaking number is ", ex2(code, nonsum))


using Test

@testset "Encoding Error" begin
    example = [
        35,
        20,
        15,
        25,
        47,
        40,
        62,
        55,
        65,
        95,
        102,
        117,
        150,
        182,
        127,
        219,
        299,
        277,
        309,
        576,
    ]

    @testset "example 1" begin
        @test ex1(example, 5) == 127
    end

    @testset "example 2" begin
        @test ex2(example, 127) == 62
    end

    @testset "results" begin
        @test ex1(code, 25) == 31161678
        @test ex2(code, 31161678) == 5453868
    end
end