using Underscores
using Utils

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
    open(aoc"13_bus-ids", "r") do f
        parse_file(f)
    end
end

function ex1(plan)
    nexts = @_ map(cld(plan.arrival, _) * _, plan.choices)
    minutes = @_ map(_ - plan.arrival, nexts)
    perm = sortperm(nexts)
    minutes[perm[1]] * plan.choices[perm[1]]
end

function combine_moduli((a1, n1), (a2, n2))
    d, m1, m2 = gcdx(n1, n2)
    @assert d == 1
    x = a1 * n2 * m2 + a2 * n1 * m1
    p = n1 * n2
    (p + x) % p, p
end

function ex2_crt(busses)
    only_nums = skipmissing(busses)

    @assert all(((a, b),) -> a == b || gcd(a, b) == 1, Iterators.product(only_nums, only_nums))

    busses = @_ only_nums |> eachindex |> map(let id = only_nums[_]; (convert(Int128, id - _ + 1), id) end, __)

    a, n = reduce(combine_moduli, busses)
    while a < 0
        a += n
    end
    a % n
end

plan = load()

println("First bus times wait time: ", ex1(plan))
println("Perfect alignment: ", ex2_crt(plan.choices))







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
        for f in [ex2_crt]
            @test f([67,7,59,61]) == 754018
            @test f([17,missing,13,19]) == 3417
            @test f([67,missing,7,59,61]) == 779210
            @test f([67,7,missing,59,61]) == 1261476
            @test f([1789,37,47,1889]) == 1202161486
            @test f(example.choices) == 1068781
        end
    end

    @testset "results" begin
        @test ex1(plan) == 8063
        @test ex2_crt(plan.choices) == 775230782877242
    end
end