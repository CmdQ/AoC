using Utils
using ProblemParser

using Lazy
using MLStyle

struct SNum
    str::AbstractString
end

@data SameOrChanged begin
    Same(SNum)
    Changed(SNum)
end
Changed(inner::String) = Changed(SNum(inner))

macro s_str(str)
    SNum(str)
end

const file = find_input(@__FILE__)
const input = parse(Lines(Map(SNum)), slurp(file))

function getinner(str::AbstractString)
    opened = 0
    comma = -1
    for i in eachindex(str)
        if str[i] == '['
            opened += 1
        elseif str[i] == ']'
            opened -= 1
            opened == 0 && return view(str, 2:i - 1), comma - 1, i - 1
        elseif str[i] == ',' && opened == 1
            comma = i
        end
    end
    error("closing bracket not found")
end

function replacematch1(str::AbstractString, (match, repl)::Pair; reversed=false)
    re = match === nothing ? str : string(
        str[begin:match.offset - 1],
        reversed ? reverse(string(repl)) : repl,
        str[match.offset + length(match.match):end],
    )
    if reversed
        re = reverse(re)
    end
    re
end

anumber = r"\d+"

function explode(num::SNum)::SameOrChanged
    str = num.str
    depth = 0
    for i in eachindex(str)
        c = str[i]
        if c == '['
            @views if depth == 4
                prefix = reverse(str[begin:i - 1])
                lhs, comma, bracket = getinner(str[i:end])
                rhs = lhs[comma + 1:end]
                lhs = lhs[begin:comma - 1]
                suffix = str[i + bracket + 1:end]

                pos = match(anumber, prefix)
                if pos !== nothing
                    number = parse.(Int, [lhs, reverse(pos.match)]) |> sum
                    prefix = replacematch1(prefix, pos => number; reversed=true)
                end

                pos = match(anumber, suffix)
                if pos !== nothing
                    number = parse.(Int, [rhs, pos.match]) |> sum
                    suffix = replacematch1(suffix, pos => number)
                end

                return string(prefix, 0, suffix) |> Changed
            else
                depth += 1
            end
        elseif c == ']'
            depth -= 1
        end
    end
    Same(num)
end

append(lhs::SNum, rhs::SNum) = string('[', lhs.str, ',', rhs.str, ']') |> SNum

append(lhs, rhs) = string('[', lhs, ',', rhs, ']')

function Base.split(num::SNum)::SameOrChanged
    for m in eachmatch(anumber, num.str)
        n = parse(Int, m.match)
        if n > 9
            lr = [n, n + 1] .÷ 2
            return replacematch1(num.str, m => append(lr...)) |> Changed
        end
    end
    Same(num)
end

function Base.reduce(num::SNum)::SNum
    while true
        num = @match explode(num) begin
            Changed(num) => num
            Same(num) => @match split(num) begin
                Changed(num) => num
                _ => return num
            end
        end
    end
end

Base.:+(lhs::SNum, rhs::SNum) = append(lhs, rhs) |> reduce

function magnitude(num::AbstractString)
    if isdigit(num[1])
        m = match(anumber, num)
        parse(Int, m.match)
    else
        lhs, comma = getinner(num)
        rhs = lhs[comma + 1:end]
        lhs = lhs[begin:comma - 1]
        3magnitude(lhs) + 2magnitude(rhs)
    end
end
magnitude(num::SNum) = magnitude(num.str)

part1(input) = @>> input foldl(+) magnitude

assertequal(part1(input), 3725)

part2(input) = maximum(magnitude(a + b) for a in input for b in input)

assertequal(part2(input), 4832)

using Test
@testset "18" begin
    @testset "addition" begin
        @test s"[[[[4,3],4],4],[7,[[8,4],9]]]" + s"[1,1]" == s"[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
    end
    @testset "replacematch1" begin
        target = "this is a foo string"
        @test replacematch1(target, match(r"fo+", target) => "bar") == "this is a bar string"
        target = reverse(target)
        @test replacematch1(target, match(r"o+f", target) => "bar"; reversed=true) == "this is a bar string"
    end
    @testset "explode" begin
        @test explode(s"[[[[[9,8],1],2],3],4]") == Changed(s"[[[[0,9],2],3],4]")
        @test explode(s"[7,[6,[5,[4,[3,2]]]]]") == Changed(s"[7,[6,[5,[7,0]]]]")
        @test explode(s"[[6,[5,[4,[3,2]]]],1]") == Changed(s"[[6,[5,[7,0]]],3]")
        @test explode(s"[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]") == Changed(s"[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
        @test explode(s"[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]") == Changed(s"[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
        @test explode(s"[[3,[2,[8,0]]],[9,[5,[4,1]]]]") == Same(s"[[3,[2,[8,0]]],[9,[5,[4,1]]]]")
    end
    @testset "split" begin
        @test split(s"[[[[0,7],4],[9,[0,9]]],[1,1]]") == Same(s"[[[[0,7],4],[9,[0,9]]],[1,1]]")
        @test split(s"[[[[0,7],4],[15,[0,13]]],[1,1]]") == Changed(s"[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
        @test split(s"[[[[0,7],4],[[7,8],[0,13]]],[1,1]]") == Changed(s"[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")
    end
    @testset "reduce" begin
        @test reduce(s"[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]") == s"[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
    end
    @testset "magnitude" begin
        @test magnitude(s"[[1,2],[[3,4],5]]") == 143
        @test magnitude(s"[[[[0,7],4],[[7,8],[6,0]]],[8,1]]") == 1384
        @test magnitude(s"[[[[1,1],[2,2]],[3,3]],[4,4]]") == 445
        @test magnitude(s"[[[[3,0],[5,3]],[4,4]],[5,5]]") == 791
        @test magnitude(s"[[[[5,0],[7,4]],[5,5]],[6,6]]") == 1137
        @test magnitude(s"[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]") == 3488
    end
end
