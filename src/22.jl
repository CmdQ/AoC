using Underscores
using Utils

const Num = Int8
const Deck = Array{Num,1}

struct Problem
    player::Array{Deck}
end

function parse_file(f)
    a = Deck()
    b = Deck()
    cur = a

    for line in eachline(f)
        if isempty(line)
            cur = b
        elseif isdigit(line[1])
            push!(cur, parse(Num, line))
        end
    end

    Problem([a, b])
end

function load()
    open(aoc"22", "r") do f
        parse_file(f)
    end
end

function score(pone, ptwo)
    winner = isempty(pone) ? ptwo : pone
    reverse!(winner)
    @_ mapreduce(_[1] * _[2], +, enumerate(winner))
end

score((pone, ptwo)) = score(pone, ptwo)

function ex1(problem::Problem)
    pone = copy(problem.player[1])
    ptwo = copy(problem.player[2])
    while !isempty(pone) && !isempty(ptwo)
        one = popfirst!(pone)
        two = popfirst!(ptwo)
        if one < two
            push!(ptwo, two)
            push!(ptwo, one)
        else
            push!(pone, one)
            push!(pone, two)
        end
    end
    score(pone, ptwo)
end

const Cache = Set

combine(pone::Deck, ptwo::Deck) = hash((pone, ptwo))

function ex2(cache::Cache, pone::Deck, ptwo::Deck, game=1, round=1)
    isempty(pone) || isempty(ptwo) && return (pone, ptwo)
    
    while !isempty(pone) && !isempty(ptwo)
        marker = combine(pone, ptwo)
        if marker in cache
            throw(:one)
        else
            push!(cache, marker)
        end
        
        one = popfirst!(pone)
        two = popfirst!(ptwo)

        if length(pone) >= one && length(ptwo) >= two
            try
                sub = ex2(Cache(), pone[1:one], ptwo[1:two], game + 1)
                if isempty(sub[1])
                    winner = ptwo
                    card = two
                else
                    winner = pone
                    card = one
                end
            catch
                winner = pone
                card = one
            end
        else
            if one < two
                winner = ptwo
                card = two
            else
                winner = pone
                card = one
            end
        end

        push!(winner, card)
        push!(winner, one ⊻ two ⊻ card)

        round += 1
    end
    pone, ptwo
end

function ex2(problem::Problem)
    score(ex2(Cache(), copy(problem.player[1]), copy(problem.player[2])))
end

problem = load()

println("Winning player's score: ", ex1(problem))
println("Recursive winner's score: ", ex2(problem))







using Test

@testset "Crab Combat" begin
    @testset "example 1" begin
        input1 = """
        Player 1:
        9
        2
        6
        3
        1
        
        Player 2:
        5
        8
        4
        7
        10
        """
        
        example1 = parse_file(IOBuffer(input1))
    
        @test ex1(example1) == 306
        @test ex2(example1) == 291
    end

    @testset "example 2" begin
        input2 = """
        Player 1:
        43
        19
        
        Player 2:
        2
        29
        14
        """
        
        example2 = parse_file(IOBuffer(input2))

        @test_throws :one ex2(example2)
    end

    @testset "results" begin
        @test ex1(problem) == 32677
        @test ex2(problem) == 33661
    end
end
