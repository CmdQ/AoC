using DataStructures
using Utils

function load()
    re = Int[]
    open(joinpath(@__DIR__, "01_expense-report.txt"), "r") do f
        for i in eachline(f)
            push!(re, parse(Int, i))
        end
    end
    re
end

# Original solution. My first Julia code ever.
# See below for a generalized, count-independent version.
function find_product2(r)
    for (o, a) in enumerate(r)
        for i in o+1:length(r)
            if a + r[i] == 2020
                return a * r[i]
            end
        end
    end
end

# Original solution. My first Julia code ever.
# See below for a generalized, count-independent version.
function find_product3(r)
    for (o, a) in enumerate(r)
        for i in o+1:length(r)
            for j in i+1:length(r)
                if a + r[i] + r[j] == 2020
                    return a * r[i] * r[j]
                end
            end
        end
    end
end

using DataStructures

function find(r, n, start = 1, which = nil())::Union{Int,Nothing}
    if start <= length(r)
        current = r[start]
        extended = cons(current, which)
        with_current = sum(extended)
        if with_current == 2020 && n == 1
            return prod(extended)
        else
            return @something_nothing find(r, n, start + 1, which) find(
                r,
                n - 1,
                start + 1,
                extended,
            )
        end
    end
end

const expenses = load()
println("Product of 2: ", find_product2(expenses))
println("Product of 3: ", find_product3(expenses))









using Test
using OffsetArrays

@testset begin
    a = [11, 222, 1010, 3333, 1010]
    b = [20, 11, 222, 1010, 3333, 2000]
    c = [11, 222, 1010, 3333, 1009, 55555, 1]
    d = [20, 11, 222, 2, 1010, 3333, 1998]

    @testset "2 loops" begin
        @test find_product2(a) == 1010 * 1010
        @test find_product2(b) == 20 * 2000
    end

    @testset "3 loops" begin
        @test find_product3(c) == 1009 * 1010
        @test find_product3(d) == 2 * 20 * 1998
    end

    finds = OffsetArray([find_product2, find_product3], 2:3)
    @testset "recursive equivalence" begin
        for i in 2:3
            @test find(a, i) == finds[i](a)
            @test find(b, i) == finds[i](b)
            @test find(c, i) == finds[i](c)
            @test find(d, i) == finds[i](d)
        end
    end

    @testset "solutions" begin
        @test find_product2(expenses) == 692916
        @test find_product3(expenses) == 289270976
    end
end
