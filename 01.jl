#!/usr/bin/julia


function load()
    re = Int[]
    open("inputs/expense-report.txt", "r") do f
        for i in eachline(f)
            push!(re, parse(Int, i))
        end
    end
    re
end

function find_product2(r::Array{Int, 1})
    for (o, a) in enumerate(r)
        for i = o+1:length(r)
            if a + r[i] == 2020
                return a * r[i]
            end
        end
    end
end

function find_product3(r::Array{Int, 1})
    for (o, a) in enumerate(r)
        for i = o+1:length(r)
            for j = i+1:length(r)
                if a + r[i] + r[j] == 2020
                    return a * r[i] * r[j]
                end
            end
        end
    end
end

const expenses = load()
println("Product of 2: ", find_product2(expenses))
println("Product of 3: ", find_product3(expenses))








using Test

@testset begin
    @testset "2 loops" begin
        @test find_product2([11, 222, 1010, 3333, 1010]) == 1010 * 1010
        @test find_product2([20, 11, 222, 1010, 3333, 2000]) == 20 * 2000
    end

    @testset "3 loops" begin
    @test find_product3([11, 222, 1010, 3333, 1009, 55555, 1]) == 1009 * 1010
    @test find_product3([20, 11, 222, 2, 1010, 3333, 1998]) == 2 * 20 * 1998
end

    @testset "solutions" begin
        @test find_product2(expenses) == 692916
        @test find_product3(expenses) == 289270976
    end
end