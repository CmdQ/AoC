using Underscores

struct BusChoice
    arrival::Int
    choices::Array{Union{Int64,Missing}}
end

function parse_file(f)
    lines = eachline(f)
    line, next = iterate(lines)
    time = parse(Int, line)
    line, next = iterate(lines, next)
    choices = @_ line |> split(__, ',') |> map(_ == "x" ? missing : parse(Int64, _), __)
    BusChoice(time, choices)
end

function load()
    open("$(@__DIR__)/../inputs/bus-ids.txt", "r") do f
        parse_file(f)
    end
end

function ex1(plan)
    nexts = @_ map(cld(plan.arrival, _) * _, plan.choices)
    minutes = @_ map(_ - plan.arrival, nexts)
    perm = sortperm(nexts)
    minutes[perm[1]] * plan.choices[perm[1]]
end

function increase(busses, atleast=0)
    greatest = atleast
    for i in eachindex(busses)
        state, num = busses[i]
        difference = atleast - state
        @assert difference >= 0
        state += cld(difference, num) * num
        busses[i] = state, num
        greatest = max(greatest, state)
    end
    greatest
end

function ex2_brute_force(busses, status=0)
    busses = @_ map(i -> (-(i[1] - 1), i[2]), enumerate(busses)) |> filter(!ismissing(_[2]), __)
    re = length(busses) - 1
    while !all(i -> i[1] == re, busses)
        re = increase(busses, re)
        if status != 0
            println(re)
        end
    end
    re
end

function combine_moduli((a1, n1), (a2, n2))
    d, m1, m2 = gcdx(n1, n2)
    println("Bezout(n1=$n1, n2=$n2) -> m1=$m1 and m2=$m2")
    @assert d == 1
    x = a1 * n2 * m2 + a2 * n1 * m1
    println("x is then $x")
    p = n1 * n2
    println("p = n1 * n2 = $p")
    (p + x) % p, p
    println("that gives \t $x ≡ (mod $(p))")
end

function ex2_crt(busses)
    only_nums = skipmissing(busses)
    @assert all(((a,b),) -> a == b || gcd(a, b) == 1 , Iterators.product(only_nums, only_nums))

    busses = @_ map((_[1] - 1, _[2]), enumerate(busses)) |> filter(!ismissing(_[2]), __)

    reduce(combine_moduli, busses)
end

reduce(combine_moduli, [(0,3),(3,4),(4,5)]) |> println
ex2_crt([67,7,59,61]) |> println
#ex2_crt([67,7,missing,59,61]) |> println
# [(0, 67), (1, 7), (3, 59), (4, 61)]    1261476

function f(a,b)
    println(a,"<->",b)
    b
end

f2(a,b) = println(a,"<->",b)

a = [(1,2),(3,4),(5,6)]
reduce(f, a)
reduce(f2, a)
#reduce(i -> i, a)
exit(0)

plan = load()

#println("First bus times wait time: ", ex1(plan))
#println(ex2_brute_force(plan.choices, 1))


using Test

@testset "Shuttle Search" begin
    input = """
    939
    7,13,x,x,59,x,31,19
    """

    example = parse_file(IOBuffer(input))
    @test example.arrival == 939
    @test length(example.choices) == 8

    @testset "example 1" begin
        @test ex1(example) == 295
    end

    @testset "example 2" begin
        @test ex2_brute_force([67,7,59,61]) == 754018
        @test ex2_brute_force([17,missing,13,19]) == 3417
        @test ex2_brute_force([67,missing,7,59,61]) == 779210
        @test ex2_brute_force([67,7,missing,59,61]) == 1261476
        @test ex2_brute_force([1789,37,47,1889]) == 1202161486
        @test ex2_brute_force(example.choices) == 1068781
    end

    @testset "results" begin
        @test ex1(plan) == 8063
    end
end