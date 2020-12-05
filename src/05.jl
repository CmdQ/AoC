#!/usr/bin/julia

function convert_seat(s::String)::Int
    replacements = [
        ('F', 'L'),
        ('B', 'R'),
    ]
    replaced = foldl((acc, (i, r)) -> replace(acc, r => i - 1), enumerate(replacements); init=s)
    parse(Int, replaced, base=2)
end

function load()::Array{Int}
    re = []
    open("$(@__DIR__)/../inputs/plane-seats.txt", "r") do f
        for line in eachline(f)
            push!(re, convert_seat(line))
        end
    end
    re
end

function find_missing_on_sorted(seats::Array{Int})::Int
    for i in 2:length(seats)
        if seats[i-1] + 2 == seats[i]
            return seats[i-1] + 1
        end
    end
end
find_missing = find_missing_on_sorted ∘ sort

seats = load()
println("Highest seat number: $(maximum(seats))")
println("My seat is $(find_missing(seats))")




using Test

@testset "Binary Boarding" begin
    @testset "example" begin
        @test convert_seat("FBFBBFFRLR") == 357
        @test convert_seat("BFFFBBFRRR") == 567
        @test convert_seat("FFFBBBFRRR") == 119
        @test convert_seat("BBFFBBFRLL") == 820
    end

    @testset "results" begin
        @test maximum(seats) == 919
        @test find_missing(seats) == 642
    end
end