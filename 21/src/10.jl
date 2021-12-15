using Utils

using Chain

inputfile = find_input(@__FILE__)
input = @chain inputfile slurp per_line(_)

const opening = "([{<"
const closing = ")]}>"
const scores = [3,57,1197,25137]

function corrupted(line::AbstractString)
    stack = Char[]
    for c in line
        pos = findfirst(c, opening)
        if pos === nothing
            pos = findfirst(c, closing)
            (isempty(stack) || pop!(stack) != c) && return scores[pos]
        else
            push!(stack, closing[pos])
        end
    end
    0
end

function part1(input)
    @chain input begin
        map(corrupted, _)
        sum
    end
end

assertequal(part1(input), 358737)

function complete(line::AbstractString)
    stack = Char[]
    for c in line
        pos = findfirst(c, opening)
        if pos === nothing
            pos = findfirst(c, closing)
            @assert pop!(stack) == c
        else
            push!(stack, closing[pos])
        end
    end
    score = 0
    while !isempty(stack)
        score = score * 5 + findfirst(==(pop!(stack)), closing)
    end
    score
end
@assert complete("<{([{{}}[<[[[<>{}]]]>[]]") == 294

function part2(input)
    completed = @chain input begin
        filter(==(0) ∘ corrupted, _)
        map(complete, _)
    end
    middle = (length(completed) + 1) ÷ 2
    partialsort!(completed, middle)
end

assertequal(part2(input), 4329504793)
