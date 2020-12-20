using Utils
using Underscores
using Chain

const TInt = Int16
const Numbers = Array{TInt,1}
const Tickets = Array{Numbers,1}

nums(str) = @_ split(str, ',') |> map(parse(TInt, _), __)

parse_range(str) = @_ split(str, '-') |> map(parse(TInt, _), __) |> reduce(:, __)

struct Rule
    name::String
    range1::UnitRange{TInt}
    range2::UnitRange{TInt}
end

Base.in(x, rule::Rule) = x in rule.range1 || x in rule.range2

struct Problem
    rules::Array{Rule}
    mine::Numbers
    nearby::Tickets
end

function parse_file(f::IO)
    prules, pmine, pnearby = @_ split(f) |> map(IOBuffer(_), __) |> map(eachline(_), __)

    rules = Rule[]
    for rule in prules
        m = match(r"^([^:]+): (\d+-\d+) or (\d+-\d+)$", rule)
        push!(rules, Rule(m[1], parse_range(m[2]), parse_range(m[3])))
    end

    nearby = Tickets()
    for line in Iterators.drop(pnearby, 1)
        push!(nearby, nums(line))
    end

    Problem(rules, nums(Iterators.only(Iterators.drop(pmine, 1))), nearby)
end

function load()
    open("$(@__DIR__)/../inputs/16.txt", "r") do f
        parse_file(f)
    end
end

function ex1(problem::Problem)
    re = 0
    valid_tickets = Tickets()
    ruls = problem.rules
    for ticket in problem.nearby
        valid = true
        for num in ticket
            if !any(r -> num in r, ruls)
                valid = false
                re += num
            end
        end
        if valid
            push!(valid_tickets, ticket)
        end
    end
    (rate = re, valid = Problem(problem.rules, problem.mine, valid_tickets))
end

problem = load()

function ex2(problem::Problem)
    mapped = Dict{Int,Int}()
    rules::Array{Union{Rule,Missing}} = copy(problem.rules)

    while length(mapped) < length(problem.rules)
        possible = Dict{Int,Set{Int}}()
        for r in eachindex(skipmissing(rules))
            for idx in eachindex(problem.rules)
                idx in values(mapped) && continue
                if all(ticket -> ticket[idx] in rules[r], problem.nearby)
                    d = get!(possible, r, Set{Int}())
                    push!(d, idx)
                end
            end
        end
        removal = false
        for (from_rule, to_indices) in possible
            # Only use the unique ones.
            if length(to_indices) == 1
                mapped[from_rule] = pop!(to_indices)
                rules[from_rule] = missing
                removal = true
            end
        end
        @assert removal
    end

    @chain problem.rules begin
        enumerate
        Iterators.filter(tup -> startswith(tup[2].name, "departure"), _)
        map(tup -> mapped[tup[1]], _)
        map(i -> problem.mine[i], _)
        prod
    end
end

answer1 = ex1(problem)
@assert length(answer1.valid.nearby) < length(problem.nearby)
println("Ticket scanning error rate: ", answer1.rate)
println("Product of departure numbers: ", ex2(answer1.valid))










using Test

@testset "Ticket Translation" begin
    @testset "example 1" begin
        input1 = """
        class: 1-3 or 5-7
        row: 6-11 or 33-44
        seat: 13-40 or 45-50

        your ticket:
        7,1,14

        nearby tickets:
        7,3,47
        40,4,50
        55,2,20
        38,6,12
        """

        example1 = parse_file(IOBuffer(input1))

        @test ex1(example1).rate == 71
        @test length(ex1(example1).valid.nearby) == 1
    end

    @testset "results" begin
        answer = ex1(problem)
        @test answer.rate == 21978
        @test ex2(answer.valid) == 1053686852011
    end
end
