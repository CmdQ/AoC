using Underscores

const MASK_PREF = "mask = "

function masked_writer(value, addr, mem, set_mask, unset_mask)
    mem[addr] = (value & unset_mask) | set_mask
end

function run_decoder(f, writer)
    mem::Dict{UInt16,UInt64} = Dict()
    set_mask::UInt64 = 0
    unset_mask = typemax(UInt64)

    for line in eachline(f)
        if startswith(line, MASK_PREF)
            set_mask = 0
            unset_mask = typemax(typeof(unset_mask))
            for bit in length(MASK_PREF)+1:length(line)
                set_mask <<= 1
                unset_mask <<= 1
                if line[bit] != '0'
                    unset_mask |= 1
                end
                if line[bit] == '1'
                    set_mask |= 1
                end
            end
        else
            m = match(r"^mem\[(\d+)\] = (\d+)$", line)
            addr = parse(keytype(mem), m[1])
            value = parse(valtype(mem), m[2])
            writer(value, addr, mem, set_mask, unset_mask)
        end
    end

    sum(values(mem))
end

function set_all(mem, addr, mask, value, lookat)
    if lookat == 0
        mem[addr] = value
    else
        while (mask & lookat) == 0
            lookat >>= 1
        end

        set_all(mem, addr | lookat, mask, value, lookat >> 1)
        set_all(mem, addr & ~lookat, mask, value, lookat >> 1)
    end
end

function run_decoder2(f)
    mem::Dict{UInt64,UInt64} = Dict()
    set_mask::UInt64 = 0
    floating_mask::UInt64 = 0

    for line in eachline(f)
        if startswith(line, MASK_PREF)
            set_mask = 0
            floating_mask = 0
            for bit in length(MASK_PREF)+1:length(line)
                set_mask <<= 1
                floating_mask <<= 1
                if line[bit] == '1'
                    set_mask |= 1
                elseif line[bit] == 'X'
                    floating_mask |= 1
                end
            end
        else
            m = match(r"^mem\[(\d+)\] = (\d+)$", line)
            addr = parse(keytype(mem), m[1]) | set_mask
            value = parse(valtype(mem), m[2])
            set_all(mem, addr, floating_mask, value, 2^35)
        end
    end

    sum(values(mem))
end

function run_decoder(writer)
    open("$(@__DIR__)/../inputs/docking-data.txt", "r") do f
        run_decoder(f, writer)
    end
end

function run_decoder2()
    open("$(@__DIR__)/../inputs/docking-data.txt", "r") do f
        run_decoder2(f)
    end
end

ex1() = run_decoder(masked_writer)
ex2() = run_decoder2()

#println("Final memory sum: ", ex1())
println("Final floating memory sum: ", ex2())








using Test

@testset "Docking Data" begin
    @testset "example 1" begin
        input = """
        mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
        mem[8] = 11
        mem[7] = 101
        mem[8] = 0
        """

        example = run_decoder(IOBuffer(input), masked_writer)

        @test example == 165
    end

    @testset "example 2" begin
        input = """
        mask = 000000000000000000000000000000X1001X
        mem[42] = 100
        mask = 00000000000000000000000000000000X0XX
        mem[26] = 1
        """

        example = run_decoder2(IOBuffer(input))

        @test example == 208
    end

    @testset "results" begin
        @test ex1() == 18630548206046
    end
end