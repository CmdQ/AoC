using Underscores
using StaticArrays

const Num = Int32

mutable struct Circle
    start::Int
    list::Array{Num,1}
end

function Circle(list)
    re = Array{Num}(undef, length(list))
    for i in 2:length(list)
        re[list[i-1]] = list[i]
    end
    re[list[end]] = list[1]
    Circle(list[1], re)
end

function parse_file(f)::Circle
    @_ collect(f) |> map(parse(Num, _), __) |> Circle
end

Base.length(circle::Circle) = length(circle.list)

Base.copy(circle::Circle) = Circle(circle.start, copy(circle.list))

Base.:(==)(lhs::Circle, rhs::Circle) = lhs.start == rhs.start && lhs.list == rhs.list

const REMOVE = 3

function extract_after(circle::Circle)
    re = MVector{REMOVE,Num}(0, 0, 0)
    which = circle.start
    for i in 1:REMOVE
        which = circle.list[which]
        re[i] = which
    end
    re
end

function insert_after!(into::Circle, what, after)
    into.list[into.start] = into.list[what[end]]
    into.list[what[end]] = into.list[after]
    into.list[after] = what[1]
end

function step!(circle::Circle)
    pickup = extract_after(circle)
    next = circle.list[pickup[end]]
    searchfor = mod1(circle.start - 1, length(circle))
    while searchfor in pickup
        searchfor = mod1(searchfor - 1, length(circle))
    end
    insert_after!(circle, pickup, searchfor)
    circle.start = next
end

function ex1(circle::Circle, rounds=10)
    circle = copy(circle)
    for i in 1:rounds
        step!(circle)
    end
    re = [] 
    itr = circle.list[1]
    while isempty(re) || itr != 1
        push!(re, itr)
        itr = circle.list[itr]
    end
    join(re)
end

const MILLION = 1_000_000

function ex2(problem::Array{Num,1}, rounds=10_000_000)
    big = collect(1:MILLION)
    big[1:length(problem)] .= problem
    circle = Circle(big)
    for i in 1:rounds
        step!(circle)
    end
    fst = circle.list[1]
    snd = circle.list[fst]
    widemul(fst, snd)
end

problem = parse_file("364289715")
println("Result of game one: ", ex1(problem))
println("Product of the huge game: ", ex2(Num[3,6,4,2,8,9,7,1,5]))








using Test

@testset "Crab Cups" begin
    example = [3,8,9,1,2,5,4,6,7]
    example_circle = Circle(example)

    @testset "circle" begin
        @test example_circle.start == 3
        @test example_circle.list[example_circle.start] == 8

        @test extract_after(example_circle).data == (8,9,1)
        
        
        @testset "insert_after!" begin
            to_change = copy(example_circle)
            after_step1 = Circle([2,8,9,1,5,4,6,7,3]) # 3 (2) 8  9  1  5  4  6  7
            after_step2 = Circle([5,4,6,7,8,9,1,3,2]) # 3  2 (5) 4  6  7  8  9  1
            after_step3 = Circle([8,9,1,3,4,6,7,2,5]) # 7  2  5 (8) 9  1  3  4  6
            after_step4 = Circle([4,6,7,9,1,3,2,5,8]) # 3  2  5  8 (4) 6  7  9  1
            
            set = to_change.list[1]
            insert_after!(to_change, [8,9,1], 2)
            to_change.start = set
            @test to_change == after_step1
            
            set = to_change.list[1]
            insert_after!(to_change, [8,9,1], 7)
            to_change.start = set
            @test to_change == after_step2
            
            set = to_change.list[7]
            insert_after!(to_change, [4,6,7], 3)
            to_change.start = set
            @test to_change == after_step3
            
            set = to_change.list[3]
            insert_after!(to_change, [9,1,3], 7)
            to_change.start = set
            @test to_change == after_step4
        end
    end

    @testset "example 1" begin
        example = parse_file("389125467")

        @test ex1(example, 10) == "92658374"
    end

    @testset "results" begin
        @test ex1(problem, 100) == "98645732"
        @test ex2(Num[3,6,4,2,8,9,7,1,5]) == 689500518476
    end
end
