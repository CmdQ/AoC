using Chain
using Utils

inputfile = replace(@__FILE__, r"\.jl$" => ".txt")
load(text) = @chain text begin
    per_split_parse(_, ',')
end
fload() = inputfile |> slurp |> load
input = fload()

const COUNT = 4

function part1(memory, replace=nothing)
    try
        memory = zerobased(copy(memory))
        if !isnothing(replace)
            memory[1] = replace[1]
            memory[2] = replace[2]
        end
        ip = 0
        while true
            opc = memory[ip]
            if opc == 99
                break
            else
                op = opc == 1 ? Base.:+ : Base.:*
                memory[memory[ip+3]] = op(memory[memory[ip+1]], memory[memory[ip+2]])
            end
            ip += 4
        end
        memory[0]
    catch BoundsError
        typemin(eltype(memory))
    end
end

function part2()
    tuples = zerobased(collect(Iterators.product(0:99, 0:99)))
    @chain tuples begin
        findfirst(t -> part1(input, t) == 19690720, _)
        get(tuples, _, 0)
        100 * _[1] + _[2]
    end
end

println("Last state before the fire: ", part1(input, (12, 2)))
println("100 * noun + verb: ", part2())
