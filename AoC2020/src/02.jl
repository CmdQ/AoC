#!/usr/bin/julia

struct Password
    counts::UnitRange{UInt8}
    character::Char
    password::String
end

function load()
    reg = r"(\d+)-(\d+) (\w): (\w+)"
    re = Password[]
    open("$(@__DIR__)/../inputs/passwords.txt", "r") do f
        for line in eachline(f)
            f, t, c, p = match(reg, line).captures
            push!(re, Password(parse(UInt8, f):parse(UInt8, t), c[1], p))
        end
    end
    re
end

function isvalid(pw::Password)
    count(c -> c == pw.character, pw.password) in pw.counts
end

function isvalid_positions(pw::Password)
    (pw.password[pw.counts.start] == pw.character) ⊻
    (pw.password[pw.counts.stop] == pw.character)
end

function count_valid(which)
    count(pw -> which(pw), pws)
end

const pws = load()
println("Valid passwords variant 1: $(count_valid(isvalid))/$(length(pws))")
println("Valid passwords variant 2: $(count_valid(isvalid_positions))/$(length(pws))")



using Test

@testset "Password problem" begin
    only_fst2 = Password(2:4, 'a', "bbbbbbbbbaa")
    only_fst3 = Password(2:4, 'a', "bbbbbbbbbaaa")
    only_fst4 = Password(2:4, 'a', "bbbbbbbbbaaaa")
    only_snd1 = Password(2:4, 'a', "babcbbbb")
    only_snd2 = Password(2:4, 'a', "bcbabbbb")

    @testset "variant 1" begin
        @test isvalid(only_fst2)
        @test isvalid(only_fst3)
        @test isvalid(only_fst4)
        @test !isvalid(only_snd1)
        @test !isvalid(only_snd2)
    end

    @testset "variant 2" begin
        @test !isvalid_positions(only_fst2)
        @test !isvalid_positions(only_fst3)
        @test !isvalid_positions(only_fst4)
        @test isvalid_positions(only_snd1)
        @test isvalid_positions(only_snd2)
    end

    @testset "solutions" begin
        @test count_valid(isvalid) == 474
        @test count_valid(isvalid_positions) == 745
    end
end