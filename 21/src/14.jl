using Utils

using Chain
import IterTools

inputfile = find_input(@__FILE__,"example.txt")
function load(fname)
    open(fname) do io
        line, rules = split_blocks(io)
        split2 = map(split(rules, '\n')) do line
            from, to = split(line, " -> ")
            ((from[1], from[2]), to[1])
        end
        (line=line, rules=Dict(split2))
    end
end
input = load(inputfile)

function polymerize(line, rules)
    next = IOBuffer(sizehint=2length(line))
    write(next, line[begin])
    for (a,b) in IterTools.partition(line, 2, 1)
        write(next, rules[String([a, b])], b)
    end
    take!(next) |> String
end

function counter(data)
    re = Dict()
    for elm in data
        re[elm] = get(re, elm, 0) + 1
    end
    re
end

function part1(input, rounds=10)::Int
    line = input.line
    for _ in 1:rounds
        line = polymerize(line, input.rules)
        end
    mi, ma = extrema(kv -> kv[2], counter(line))
    ma - mi
end

assertequal(part1(input), 3048)

function part2(input, rounds=10)
    line = input.line
    pairs = Dict{Tuple{Char,Char},Int}()
    for tup in IterTools.partition(line, 2, 1)
        pairs[tup] = get(pairs, tup, 0) + 1
    end
    display(pairs)
    for _ in 1:rounds
        next = Dict{Tuple{Char,Char},Int}() # ('#', line[begin]) => 1, (line[end], '#') => 1
        for pair in keys(pairs)
            middle = input.rules[pair]
            tup = pair[1], middle
            next[tup] = get(pairs, tup, 0) + 1
            tup = middle, pair[2]
            next[tup] = get(pairs, tup, 0) + 1
        end
        pairs = next
        display(pairs)
    end
    letters = Dict{Char, Int}()
    for ((a,_),count) in pairs
        println(a," ",count)
        letters[a] = get(letters, a, 0) + count
        #letters[b] = get(letters, b, 0) + 1
    end
    letters[line[begin]] += 1
    #letters[line[end]] = get(letters, line[end], 0) + 1
    letters
end

@run assertequal(part2(input, 3), 1588)
assertequal(part2(input, 3), 1588)

"""
Template:     NNCB                           N 2   C 1   B  1
After step 1: NCNBCHB                        N 2   C 2   B  2   H 1
After step 2: NBCCNBBBCBHCB                  N 2   C 4   B  6   H 1
After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB      N 5   C 5   B 11   H 4
""""