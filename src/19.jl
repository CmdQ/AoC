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

correct1 = ["aaaabb", "aaabab", "abbabb", "abbbab", "aabaab", "aabbbb", "abaaab", "ababbb"]
for correct in correct1
    @assert occursin(build_regex(example1.rules), correct)
end


@show build_regex(example1.rules)

function rule_walker(rules::Rules, str, current, pos)
    pos > length(str) && return pos
    
    if isa(current, Rule)
        rule = current
    else
        rule = rules[current]
    end
    
    if isa(rule, Rule)
        for ref in rule.refs
            pos = rule_walker(rules, str, ref, pos)
            !(pos in eachindex(str)) && return pos
        end
        pos
    elseif isa(rule, Alternative)
        left = rule_walker(rules, str, Rule(rule.left), pos)
        left != 0 && return left
        rule_walker(rules, str, Rule(rule.right), pos)
    else
        startswith(str[pos:end], rule) ? pos + length(rule) : 0
    end
end
rule_walker(rules, str) = rule_walker(rules, str, 0, 1) == length(str) + 1
#@run rule_walker(example1.rules, example1.messages[3])

@show rule_walker(Rules(0 => "ab", 2 => "c"), "ab", 0, 1)
@show rule_walker(Rules(0 => Rule([1, 2]), 1 => "ab", 2 => "c"), "abc")
@show rule_walker(Rules(0 => Rule([1, 4]), 1 => "ab", 2 => "c", 3 => "d", 4 => Alternative([2], [3])), "abc")
@show rule_walker(Rules(0 => Rule([1, 4]), 1 => "ab", 2 => "c", 3 => "d", 4 => Alternative([2], [3])), "abd")
@show rule_walker(Rules(0 => Rule([1, 4]), 1 => "ab", 2 => "c", 3 => "d", 4 => Alternative([2], [3])), "abe")
@show rule_walker(Rules(0 => Rule([1, 4]), 1 => "ab", 2 => "c", 3 => "d", 4 => Alternative([2], [3])), "zabc")
@show rule_walker(Rules(0 => Rule([1, 4, 5]), 1 => "ab", 2 => "c", 3 => "d", 4 => Alternative([2], [3]), 5 => "xyz"), "abdxyz")

@show example1.messages
for msg in example1.messages
    @show rule_walker(example1.rules, msg)
end

function ex2(messages)
    changed = copy(messages.rules)
    changed[8] = Alternative([42], [42, 8])
    changed[11] = Alternative([42, 31], [42, 11, 31])

    @_ count(rule_walker(changed, _), messages.messages)
end


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
changed = copy(example2.rules)
changed[8] = Alternative([42], [42, 8])
changed[11] = Alternative([42, 31], [42, 11, 31])

@show rule_walker(changed, example2.messages[12])

for s in example2.messages

    #@show rule_walker(example2.rules, s)
    @show rule_walker(changed, s)
end


println("Matching after change: ", ex2(messages))

exit(0)
println("Number of matching messages: ", ex1(messages))




using Test

@testset "" begin
    @testset "example 1" begin
    end

    @testset "example 2" begin
    end

    @testset "results" begin
    end
end
