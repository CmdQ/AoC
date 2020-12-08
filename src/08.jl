using Underscores

function parse_file(f)
    @_ eachline(f) |> map(let t = split(_); t[1], parse(Int, t[2]) end, __)
end

function load()
    open("$(@__DIR__)/../inputs/bootcode.txt", "r") do f
        parse_file(f)
    end
end

assembly = load()

struct Infinite
    acc::Int
end

struct Finished
    acc::Int
end

function ex1(assembly)::Union{Infinite,Finished}
    valid = eachindex(assembly)
    ran = zeros(Bool, valid.stop)
    acc = 0
    pc = 1
    while pc in valid
        if ran[pc]
            return Infinite(acc)
        end
        ins, arg = assembly[pc]
        ran[pc] = true
        if ins == "acc"
            acc += arg
        elseif ins == "jmp"
            pc += arg
            continue
        end
        pc += 1
    end
    Finished(acc)
end

function ex2(assembly)
    for i in eachindex(assembly)
        before = assembly[i]
        ins, arg = before
        if ins == "jmp"
            assembly[i] = "nop", arg
            acc = ex1(assembly)
            assembly[i] = before
            if isa(acc, Finished)
                return acc
            end
        elseif ins == "nop"
            assembly[i] = "jmp", arg
            acc = ex1(assembly)
            assembly[i] = before
            if isa(acc, Finished)
                return acc
            end
        end
    end
end

println("Accumulator before infinite loop: ", ex1(assembly))
println("Accumulator after  finished  run: ", ex2(assembly))




using Test

@testset "Handy Haversacks" begin
    input = """
        nop +0
        acc +1
        jmp +4
        acc +3
        jmp -3
        acc -99
        acc +1
        jmp -4
        acc +6
        """

    example = parse_file(IOBuffer(input))

    @testset "example 1" begin
        @test ex1(example) == Infinite(5)
        @test ex2(example) == Finished(8)
    end

    @testset "results" begin
        @test ex1(assembly) == Infinite(1928)
        @test ex2(assembly) == Finished(1319)
    end
end