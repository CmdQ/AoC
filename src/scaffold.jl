#!/usr/bin/julia

function load()
    re = []
    open("$(@__DIR__)/../inputs/.txt", "r") do f
        for line in eachline(f)
        end
    end
    re
end







using Test

@testset "" begin
    @testset "example" begin
    end

    @testset "results" begin
    end
end