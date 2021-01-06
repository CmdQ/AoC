using Underscores
using Utils

function parse_file(f)
    @_ map(parse(Int16, _), eachline(f))
end

function load()
    open(joinpath(@__DIR__, "10_jolt.txt"), "r") do f
        parse_file(f)
    end
end

function ex1(adapters)
    sort!(adapters)
    diffs::Array{Int16} = zeros(3)
    i = 2
    while i <= length(adapters)
        if adapters[i] > adapters[i-1] + 3
            throw("out")
        end
        diffs[adapters[i]-adapters[i-1]] += 1
        i += 1
    end
    (diffs[1] + 1) * (diffs[3] + 1)
end

const DIFF = 3

function ex2(cache, adapters, i)
    haskey(cache, i) && return cache[i]

    if i == 1
        Int(adapters[1] <= DIFF)
    elseif i == 2
        Int(adapters[2] - adapters[1] <= DIFF >= adapters[1]) + Int(adapters[2] <= DIFF)
    elseif i == 3
        jolt = adapters[i]
        base = ex2(cache, adapters, i - 1) + Int(jolt <= DIFF)
        if jolt - adapters[i-2] <= DIFF
            base += ex2(cache, adapters, i - 2)
        end
        base
    else
        jolt = adapters[i]
        base = ex2(cache, adapters, i - 1)
        if jolt - adapters[i-2] <= DIFF
            base += ex2(cache, adapters, i - 2)
        end
        if jolt - adapters[i-3] <= DIFF
            base += ex2(cache, adapters, i - 3)
        end
        cache[i] = base
        base
    end
end

function ex2(adapters)
    sort!(adapters)
    cache = Dict(0 => 1)
    ex2(cache, adapters, length(adapters))
end

adapters = load()

println("Product of Jolt differences: ", ex1(adapters))
println("Number of combinations: ", ex2(adapters))










using Test

@testset "Adapter Array" begin
    example = [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4]

    example2 = [
        28,
        33,
        18,
        42,
        31,
        14,
        46,
        20,
        48,
        47,
        24,
        23,
        49,
        45,
        19,
        38,
        39,
        11,
        1,
        32,
        25,
        35,
        8,
        17,
        7,
        9,
        4,
        2,
        34,
        10,
        3,
    ]

    @testset "example 1" begin
        @test ex1(example) == 7 * 5
        @test ex1(example2) == 22 * 10
    end

    @testset "example 2" begin
        @test ex2([1, 4, 7, 10]) == 1
        @test ex2([1, 4, 5, 7, 10]) == 2
        @test ex2([1, 4, 5, 6, 7, 10]) == 4
        @test ex2([1, 4, 5, 6, 7, 9, 10]) == 10

        @test ex2(example) == 8
        @test ex2(example2) == 19208
    end

    @testset "results" begin
        @test ex1(adapters) == 2277
        @test ex2(adapters) == 37024595836928
    end
end
