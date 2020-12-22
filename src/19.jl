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
    open("$(@__DIR__)/../inputs/19.txt", "r") do f
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

show_depth = 1

function rule_walker(rules::Rules, str, current::AbstractString, pos, depth=1)
    startswith(str[pos:end], current) ? pos + length(current) : 0
end

@assert rule_walker(Rules(), "abcd", "ab", 1) == 3
@assert rule_walker(Rules(), "abcd", "abc", 1) == 4
@assert rule_walker(Rules(), "abcd", "d", 4) == 5
@assert rule_walker(Rules(), "abcd", "bc", 2) == 4
@assert rule_walker(Rules(), "abcd", "bc", 1) == 0

function rule_walker(rules::Rules, str, current::Int, pos, depth=1)
    rule_walker(rules, str, rules[current], pos, depth)
end

@assert rule_walker(Rules(0 => "ab"), "abcd", 0, 1) == 3
@assert rule_walker(Rules(1 => "abc"), "abcd", 1, 1) == 4
@assert rule_walker(Rules(2 => "d"), "abcd", 2, 4) == 5
@assert rule_walker(Rules(3 => "bc"), "abcd", 3, 2) == 4
@assert rule_walker(Rules(4 => "bc"), "abcd", 4, 1) == 0

function rule_walker(rules::Rules, str, current::Alternative, pos, depth=1)
    left = rule_walker(rules, str, Rule(current.left), pos, depth + 1)
    rigt = rule_walker(rules, str, Rule(current.right), pos, depth + 1)
    depth == show_depth && println("ALT $depth: for len() = $(length(str)) two choices $left and $rigt")
    if left >= 0
        @assert !(rigt in eachindex(str))
        depth == show_depth && println("ALT $depth: return $left in first if")
        left
    else
        @assert !(left in eachindex(str))
        depth == show_depth && println("ALT $depth: return $rigt in second if")
        rigt
    end
end

function rule_walker(rules::Rules, str, current::Rule, pos, depth=1)
    for (i,ref) in enumerate(current.refs)
        depth == show_depth && println("RULE $depth: check str[$pos:] = $(str[1:pos-1])|$(str[pos:end]) with $ref")
        pos = rule_walker(rules, str, ref, pos, depth + 1)
        pos == 0 && return 0
        if pos > length(str)
            depth == show_depth && println("RULE $depth: pos is off at $ref")
            if i == lastindex(current.refs)
                depth == show_depth && println("RULE $depth: so return $pos")
                return pos
            else
                depth == show_depth && println("RULE $depth: 0 it is")
                return 0
            end
        end
    end
    depth == show_depth && println("RULE $depth: loop terminated")
    pos
end

@assert rule_walker(Rules(0 => Alternative([1, 2], [2, 1]), 1 => "ab", 2 => "cd"), "abcd", 0, 1) == 5
@assert rule_walker(Rules(0 => Alternative([1, 2], [2, 1]), 1 => "ab", 2 => "cde"), "abcd", 0, 1) == 0
@assert rule_walker(Rules(0 => Alternative([1, 2], [2, 3]), 1 => "ab", 2 => "cd", 3 => "cde"), "abcd", 0, 1) == 5
@enter rule_walker(Rules(0 => Alternative([1, 2], [1, 3]), 1 => "ab", 2 => "cd", 3 => "cde"), "abcde", 0, 1) == 6
@assert rule_walker(Rules(0 => Rule([9, 10]), 9 => Alternative([1, 2], [1, 3]), 1 => "ab", 2 => "cd", 3 => "cde"), 10 => "z", "abcdez", 0, 1) == 7

@assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "b", 2 => "a"), "ab", 0, 1) == 0
@assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "ab", 0, 1) == 3
@assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "abc", 0, 1) == 0
@assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => Alternative([3], [3, 4]), 3 => "b", 4 => "c"), "abc", 0, 1) == 4

#=
function rule_walker(rules::Rules, str, current, pos)
    pos > length(str) && return pos

    if isa(current, Rule)
        rule = current
    else
        rule = rules[current]
    end

    if isa(rule, Rule)
        checked = length(rule.refs)
        for ref in rule.refs
            pos = rule_walker(rules, str, ref, pos)
            pos == length(str) + 1 && checked == 1 && return pos
            pos in eachindex(str) || break
            checked -= 1
        end
        checked == 0 ? pos : 0
    elseif isa(rule, Alternative)
        left = rule_walker(rules, str, Rule(rule.left), pos)
        left in eachindex(str) && return left
        right = rule_walker(rules, str, Rule(rule.right), pos)
        right
    else
        re = startswith(str[pos:end], rule) ? pos + length(rule) : 0
        re
    end
end
=#

function rule_walker(rules, str)
    check = rule_walker(rules, str, 0, 1)
    show_depth > 0 && println("the final result was $check")
    check > length(str)
end
@run rule_walker(exs[1].rules, exs[1].messages[3])


@assert !rule_walker(Rules(0 => Rule([1, 2]), 1 => "b", 2 => "a"), "ab")
@assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "ab")
@assert !rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => "b"), "abc")
@assert rule_walker(Rules(0 => Rule([1, 2]), 1 => "a", 2 => Alternative([3], [3, 4]), 3 => "b", 4 => "c"), "abc")

function examples()
    show_depth = 0
    #=
    1234567
    ababbb
    bababa  no
    abbbab 
    aaabbb  no
    aaaabbb no
    =#
    exs = Messages[
        Messages(Dict{Int64,Union{AbstractString, Alternative, Rule}}(0 => Rule([4, 1, 5]),4 => "a",2 => Alternative([4, 4], [5, 5]),3 => Alternative([4, 5], [5, 4]),5 => "b",1 => Alternative([2, 3], [3, 2])), SubString["ababbb", "bababa", "abbbab", "aaabbb", "aaaabbb"]),
        Messages(Dict{Int64,Union{AbstractString, Alternative, Rule}}(18 => Rule([15, 15]),2 => Alternative([1, 24], [14, 4]),16 => Alternative([15, 1], [14, 14]),11 => Rule([42, 31]),21 => Alternative([14, 1], [1, 14]),0 => Rule([8, 11]),9 => Alternative([14, 27], [1, 26]),25 => Alternative([1, 1], [1, 14]),10 => Alternative([23, 14], [28, 1]),42 => Alternative([9, 14], [10, 1]),26 => Alternative([14, 22], [1, 20]),7 => Alternative([14, 5], [1, 21]),19 => Alternative([14, 1], [14, 14]),17 => Alternative([14, 2], [1, 7]),8 => Rule([42]),22 => Rule([14, 14]),6 => Alternative([14, 14], [1, 14]),24 => Rule([14, 1]),4 => Rule([1, 1]),3 => Alternative([5, 14], [16, 1]),28 => Rule([16, 1]),5 => Alternative([1, 14], [15, 1]),20 => Alternative([14, 14], [1, 15]),23 => Alternative([25, 1], [22, 14]),31 => Alternative([14, 17], [1, 13]),13 => Alternative([14, 3], [1, 12]),14 => "b",27 => Alternative([1, 6], [14, 18]),15 => Alternative([1], [14]),12 => Alternative([24, 14], [19, 1]),1 => "a"),
            SubString["abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa", "bbabbbbaabaabba", "babbbbaabbbbbabbbbbbaabaaabaaa", "aaabbbbbbaaaabaababaabababbabaaabbababababaaa", "bbbbbbbaaaabbbbaaabbabaaa", "bbbababbbbaaaaaaaabbababaaababaabab", "ababaaaaaabaaab", "ababaaaaabbbaba", "baabbaaaabbaaaababbaababb", "abbbbabbbbaaaababbbbbbaaaababb", "aaaaabbaabaaaaababaa", "aaaabbaaaabbaaa", "aaaabbaabbaaaaaaabbbabbbaaabbaabaaa", "babaaabbbaaabaababbaabababaaab", "aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba"]),
        Messages(Dict{Int64,Union{AbstractString, Alternative, Rule}}(18 => Rule([15, 15]),2 => Alternative([1, 24], [14, 4]),16 => Alternative([15, 1], [14, 14]),11 => Alternative([42, 31], [42, 11, 31]),21 => Alternative([14, 1], [1, 14]),0 => Rule([8, 11]),9 => Alternative([14, 27], [1, 26]),25 => Alternative([1, 1], [1, 14]),10 => Alternative([23, 14], [28, 1]),42 => Alternative([9, 14], [10, 1]),26 => Alternative([14, 22], [1, 20]),7 => Alternative([14, 5], [1, 21]),19 => Alternative([14, 1], [14, 14]),17 => Alternative([14, 2], [1, 7]),8 => Alternative([42], [42, 8]),22 => Rule([14, 14]),6 => Alternative([14, 14], [1, 14]),24 => Rule([14, 1]),4 => Rule([1, 1]),3 => Alternative([5, 14], [16, 1]),28 => Rule([16, 1]),5 => Alternative([1, 14], [15, 1]),20 => Alternative([14, 14], [1, 15]),23 => Alternative([25, 1], [22, 14]),31 => Alternative([14, 17], [1, 13]),13 => Alternative([14, 3], [1, 12]),14 => "b",27 => Alternative([1, 6], [14, 18]),15 => Alternative([1], [14]),12 => Alternative([24, 14], [19, 1]),1 => "a"),
            SubString["abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa", "bbabbbbaabaabba", "babbbbaabbbbbabbbbbbaabaaabaaa", "aaabbbbbbaaaabaababaabababbabaaabbababababaaa", "bbbbbbbaaaabbbbaaabbabaaa", "bbbababbbbaaaaaaaabbababaaababaabab", "ababaaaaaabaaab", "ababaaaaabbbaba", "baabbaaaabbaaaababbaababb", "abbbbabbbbaaaababbbbbbaaaababb", "aaaaabbaabaaaaababaa", "aaaabbaaaabbaaa", "aaaabbaabbaaaaaaabbbabbbaaabbaabaaa", "babaaabbbaaabaababbaabababaaab", "aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba"])
    ]
    #throw("stop")
    
    for e in exs, (i,m) in enumerate(e.messages)
        i == 1 && println("------------------------")
        println(i, " ", rule_walker(e.rules, m))
    end

    #@run rule_walker(example3.rules, example3.messages[2]) == true
    #@run rule_walker(example3.rules, example3.messages[12]) == false
end
examples()





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

        @show [example1, example2, example3]
    end

    @testset "results" begin
        @test ex1(messages) == 205
    end
end
