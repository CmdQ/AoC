using Utils

using Chain
using CompositeStructs
import IterTools

inputfile = find_input(@__FILE__)
input = inputfile |> slurp

function bitvector(input::AbstractString)
    @assert length(input) % 2 == 0 "input has length $(length(input))"
    bytes = @chain input IterTools.partition(_, 2) map(c -> parse(UInt8, join(c), base=16), _)
    re = BitVector((byte & (1 << i)) != 0 for byte=bytes for i=7:-1:0)
    append!(re, [false, false, false])
    re
end
@assert bitvector("D2")[1:8] == [true, true, false, true, false, false, true, false]
@assert bitvector("FE")[1:8] == [true, true, true, true, true, true, true, false]
@assert bitvector("FED2")[1:16] == [true, true, true, true, true, true, true, false, true, true, false, true, false, false, true, false]

decimal(bits::AbstractArray{Bool}) = foldl((l,r) -> (l << 1) | r, bits, init=0)
@assert decimal([true,true,false]) == 6

struct Packet
    version::UInt8
    type::UInt8
    content::Union{Int,Vector{Packet}}
end

function decode(bv::BitVector, pos=1; limit=-1)
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
                inc, children = decode(bv[pos:end]; limit=len)
            else
                len = decimal(bv[pos+1:pos+15])
                pos += 1 + 15
                inc, children = decode(bv[pos:pos+len-1])
            end
            return pos + inc - 1, [Packet(version, type, children)]
        end
        if limit > 0
            limit -= 1
        end
    end
    pos, found
end
decode(string::AbstractString) = string |> bitvector |> decode
@run decode("620080001611562C8802118E34")
decode("620080001611562C8802118E34" |> bitvector)

decode("EE00D40C823060")
decode("38006F45291200")
decode("C0015000016115A2E0802F182340")

function sumversions(paket::Packet)
    re = paket.version
    if !isa(paket.content, Number)
        re += map(sumversions, paket.content) |> sum
    end
    re
end

sumversions(pakets::Vector{Packet}) = map(sumversions, pakets)

function part1(input)
    @chain input begin
        decode
        _[2]
        sumversions
        sum
        convert(Int, _)
    end
end

@assert part1("8A004A801A8002F478") == 16
@assert part1("620080001611562C8802118E34") == 12
@assert part1("C0015000016115A2E0802F182340") == 23
@assert part1("A0016C880162017C3686B18A3D4780") == 31

function part2(input)
end

assertequal(part2(input))

