using Utils

using Chain
import IterTools

inputfile = find_input(@__FILE__)#,"example.txt")
function load(fname)
    open(fname) do io
        line, rules = split_blocks(io)
        (line=line, rules=Dict(map(curry2nd(split, " -> "), split(rules, '\n'))))
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
    println(line)
    println(extrema(kv -> kv[2], counter(line)), "\n")
    for _ in 1:rounds
        line = polymerize(line, input.rules)
        println(line)
        println(extrema(kv -> kv[2], counter(line)), "\n")
        end
    mi, ma = extrema(kv -> kv[2], counter(line))
    ma - mi
end

assertequal(part1(input), 3048)

#part2 = curry2nd(part1, 40)
#assertequal(part2(input))
