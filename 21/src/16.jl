using Utils

using Chain
using CompositeStructs

import IterTools

const file = find_input(@__FILE__)
const input = file |> slurp

struct Packet
    version::UInt8
    type::UInt8
    content::Union{Int,Vector{Packet}}
end

function bitvector(input::AbstractString)
    @assert length(input) % 2 == 0 "input has length $(length(input))"
    bytes = @chain input IterTools.partition(_, 2) map(c -> parse(UInt8, join(c), base=16), _)
    re = BitVector((byte & (1 << i)) != 0 for byte=bytes for i=7:-1:0)
    # Make sure there's enought to read packets of 4.
    push!(re, false, false, false)
end

decimal(bits::AbstractArray{Bool}) = foldl((l,r) -> (l << 1) | r, bits, init=0)

function decode(bv::BitVector, limit, pos=1)::Tuple{Int,Vector{Packet}}
    found = Packet[]
    while pos <= length(bv) && limit != 0
        version = decimal(bv[pos:pos+2])
        pos += 3
        type = decimal(bv[pos:pos+2])
        pos += 3
        if type == 4
            num = 0
            while true
                chunk = decimal(bv[pos:pos+4])
                pos += 5
                num = (num << 4) | (chunk & 0b1111)
                ((chunk & 0b10000) == 0) && break
            end
            push!(found, Packet(version, type, num))
        else
            if bv[pos]
                len = decimal(bv[pos+1:pos+11])
                pos += 1 + 11
                inc, children = decode(bv[pos:end], len)
            else
                len = decimal(bv[pos+1:pos+15])
                pos += 1 + 15
                inc, children = decode(bv[pos:pos+len-1], -1)
            end
            pos += inc - 1
            push!(found, Packet(version, type, children))
        end
        limit > 0 && (limit -= 1)
    end
    pos, found
end

decode(string::AbstractString) = @chain string bitvector decode(1)

function sumversions(paket::Packet)::Int
    re = paket.version
    if !isa(paket.content, Number)
        re += map(sumversions, paket.content) |> sum
    end
    re
end

function part1(input)::Int
    @chain input begin
        decode
        _[2]
        only
        sumversions
        sum
    end
end

assertequal(part1(input), 965)

function part2(pak::Packet)::Int
    pak.type == 4 && return pak.content
    evald = part2.(pak.content)
    if pak.type == 0
        sum(evald)
    elseif pak.type == 1
        prod(evald)
    elseif pak.type == 2
        minimum(evald)
    elseif pak.type == 3
        maximum(evald)
    else
        @assert length(evald) == 2
        left, right = evald
        bool = if pak.type == 5
            left > right
        elseif pak.type == 6
            left < right
        elseif pak.type == 7
            left == right
        end
        convert(Int, bool)
    end
end

part2(input) = decode(input)[2] |> only |> part2

assertequal(part2(input), 116672213160)

using Test

@testset "utilities" begin
    @test bitvector("D2")[1:8] == [true, true, false, true, false, false, true, false]
    @test bitvector("FE")[1:8] == [true, true, true, true, true, true, true, false]
    @test bitvector("FED2")[1:16] == [true, true, true, true, true, true, true, false, true, true, false, true, false, false, true, false]
    @test decimal([true,true,false]) == 6
    @test part1("8A004A801A8002F478") == 16
    @test part1("620080001611562C8802118E34") == 12
    @test part1("C0015000016115A2E0802F182340") == 23
    @test part1("A0016C880162017C3686B18A3D4780") == 31
end
