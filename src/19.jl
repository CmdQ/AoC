using Utils
using Underscores

nums(s) = @_ split(s) |> map(parse(Int, _), __)

struct Rule
    refs::Array{Int}
end

struct Alternative
    left::Array{Int}
    right::Array{Int}
end

const RulePossibilities = Union{AbstractString,Rule,Alternative}
const Rules = Dict{Int,RulePossibilities}

struct Messages
    rules::Rules
    messages::Array{SubString}
end

function parse_file(f)
    rules, messages = split(f)

    rls = Rules()
    for line in eachline(IOBuffer(rules))
        head, content = split(line, ": ")
        head = parse(Int, head)
        if startswith(content, '"')
            rls[head] = strip(content, '"')
        else
            if occursin('|', content)
                a, b = split(content, " | ")
                rls[head] = Alternative(nums(a), nums(b))
            else
                rls[head] = Rule(nums(content))
            end
        end
    end
    Messages(rls, collect(eachline(IOBuffer(messages))))
end

function load()
    open(aoc"19", "r") do f
        parse_file(f)
    end
end

messages = load()

function build_regex(rules::Rules, current)
    current = rules[current]
    if isa(current, Alternative)
        lefts = @_ current.left |> map(build_regex(rules, _), __) |> join
        rights = @_ current.right |> map(build_regex(rules, _), __) |> join
        "(?:$lefts|$rights)"
    elseif isa(current, Rule)
        @_ current.refs |> map(build_regex(rules, _), __) |> join
    else
        current
    end
end

build_regex(rules) = '^' * build_regex(rules, 0) * '$' |> Regex

function ex1(messages)
    re = build_regex(messages.rules)
    @_ count(occursin(re, _), messages.messages)
end

function rule_walker(_, str, current::AbstractString, pos)::Array{Int,1}
    [startswith(str[pos:end], current) ? pos + length(current) : 0]
end


function rule_walker(rules::Rules, str, current::Int, pos)::Array{Int,1}
    rule_walker(rules, str, rules[current], pos)
end

function rule_walker(rules::Rules, str, current::Alternative, pos)::Array{Int,1}
    re = rule_walker(rules, str, Rule(current.left), pos)
    append!(re, rule_walker(rules, str, Rule(current.right), pos))
    filter(p -> p != 0, re)
end

function rule_walker(rules::Rules, str, current::Rule, pos)::Array{Int,1}
    positions = [pos]
    for (i,ref) in enumerate(current.refs)
        positions = @_ map(rule_walker(rules, str, ref, _), positions) |> Iterators.flatten |> collect
        if i < lastindex(current.refs)
            filter!(p -> p in eachindex(str), positions)
        end
    end
    positions
end

rule_walker(rules, str) = (length(str) + 1) in rule_walker(rules, str, 0, 1)

function ex2(messages, update=true)
    changed = copy(messages.rules)
    if update
        changed[8] = Alternative([42], [42, 8])
        changed[11] = Alternative([42, 31], [42, 11, 31])
    end

    @_ count(rule_walker(changed, _), messages.messages)
end

println("Number of matching messages: ", ex1(messages))
println("Matching after change: ", ex2(messages))







using Test

@testset "Monster Messages" begin
    input1 = """
    0: 4 1 5
    1: 2 3 | 3 2
    2: 4 4 | 5 5
    3: 4 5 | 5 4
    4: "a"
    5: "b"

    ababbb
    bababa
    abbbab
    aaabbb
    aaaabbb
    """

    example1 = parse_file(IOBuffer(input1))

    input2 = """
    42: 9 14 | 10 1
    9: 14 27 | 1 26
    10: 23 14 | 28 1
    1: "a"
    11: 42 31
    5: 1 14 | 15 1
    19: 14 1 | 14 14
    12: 24 14 | 19 1
    16: 15 1 | 14 14
    31: 14 17 | 1 13
    6: 14 14 | 1 14
    2: 1 24 | 14 4
    0: 8 11
    13: 14 3 | 1 12
    15: 1 | 14
    17: 14 2 | 1 7
    23: 25 1 | 22 14
    28: 16 1
    4: 1 1
    20: 14 14 | 1 15
    3: 5 14 | 16 1
    27: 1 6 | 14 18
    14: "b"
    21: 14 1 | 1 14
    25: 1 1 | 1 14
    22: 14 14
    8: 42
    26: 14 22 | 1 20
    18: 15 15
    7: 14 5 | 1 21
    24: 14 1
    
    abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
    bbabbbbaabaabba
    babbbbaabbbbbabbbbbbaabaaabaaa
    aaabbbbbbaaaabaababaabababbabaaabbababababaaa
    bbbbbbbaaaabbbbaaabbabaaa
    bbbababbbbaaaaaaaabbababaaababaabab
    ababaaaaaabaaab
    ababaaaaabbbaba
    baabbaaaabbaaaababbaababb
    abbbbabbbbaaaababbbbbbaaaababb
    aaaaabbaabaaaaababaa
    aaaabbaaaabbaaa
    aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
    babaaabbbaaabaababbaabababaaab
    aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
    """
    
    example2 = parse_file(IOBuffer(input2))

    @testset "interna" begin
        @testset "string rule" begin
            @test rule_walker(Rules(), "abcd", "ab", 1) == [3]
            @test rule_walker(Rules(), "abcd", "abc", 1) == [4]
            @test rule_walker(Rules(), "abcd", "d", 4) == [5]
            @test rule_walker(Rules(), "abcd", "bc", 2) == [4]
            @test rule_walker(Rules(), "abcd", "bc", 1) == [0]
        end
        
        @testset "int rule" begin
            @assert rule_walker(Rules(0 => "ab"), "abcd", 0, 1) == [3]
            @assert rule_walker(Rules(1 => "abc"), "abcd", 1, 1) == [4]
            @assert rule_walker(Rules(2 => "d"), "abcd", 2, 4) == [5]
            @assert rule_walker(Rules(3 => "bc"), "abcd", 3, 2) == [4]
            @assert rule_walker(Rules(4 => "bc"), "abcd", 4, 1) == [0]
        end
        
        @testset "alternative rule" begin
            @assert 5 in rule_walker(Rules(0 => Alternative([1, 2], [2, 1]), 1 => "ab", 2 => "cd"), "abcd", 0, 1)
            @assert rule_walker(Rules(0 => Alternative([1, 2], [2, 1]), 1 => "ab", 2 => "cde"), "abcd", 0, 1) == []
            @assert 5 in rule_walker(Rules(0 => Alternative([1, 2], [2, 3]), 1 => "ab", 2 => "cd", 3 => "cde"), "abcd", 0, 1)
            @assert 6 in rule_walker(Rules(0 => Alternative([1, 2], [1, 3]), 1 => "ab", 2 => "cd", 3 => "cde"), "abcde", 0, 1)
            @assert 7 in rule_walker(Rules(0 => Rule([9, 10]), 9 => Alternative([1, 2], [1, 3]), 1 => "ab", 2 => "cd", 3 => "cde", 10 => "z"), "abcdez", 0, 1)
        end
        
        @testset "rule" begin
            @assert !(4 in rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "abc", 0, 1))
            @assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "b", 2 => "a"), "ab", 0, 1) == []
            @assert 3 in rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "ab", 0, 1)
            @assert 4 in rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => Alternative([3], [3, 4]), 3 => "b", 4 => "c"), "abc", 0, 1)
        end
        
        @testset "shell" begin
            @assert !rule_walker(Rules(0 => Rule([1, 2]), 1 => "b", 2 => "a"), "ab")
            @assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "ab")
            @assert !rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "abc")
            @assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => Alternative([3], [3, 4]), 3 => "b", 4 => "c"), "abc")
        end
    end    

    @testset "example 1" begin
        @test ex1(example1) == 2
        @test ex1(example2) == 3
    end

    @testset "example 2" begin
        example3 = Messages(copy(example2.rules), example2.messages)
        example3.rules[8] = Alternative([42], [42, 8])
        example3.rules[11] = Alternative([42, 31], [42, 11, 31])

        @test ex2(example1, false) == 2
        @test ex2(example2, false) == 3
        @test ex2(example3, false) == 12
    end

    @testset "results" begin
        @test ex1(messages) == 205
        @test ex2(messages) == 329
    end
end
