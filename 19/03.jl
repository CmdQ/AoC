using Underscores
using Utils
using OffsetArrays

dirs = Dict(
    'D' => (1, 0),
    'U' => (-1, 0),
    'L' => (0, -1),
    'R' => (0, 1),
)

const Num = Int32

function parse_dir(item)
    d = item[1]
    parsed = parse(Num, item[2:end])
    CartesianIndex(dirs[d] .* parsed)
end

Input = @NamedTuple{wires::Array{Array{CartesianIndex,1},1}, min::CartesianIndex{2}, max::CartesianIndex{2}}

inputfile = "$(replace(@__FILE__, r".jl$" => "")).txt"
function load(text)::Input
    mi = CartesianIndex(0, 0)
    ma = CartesianIndex(0, 0)
    re = Array{CartesianIndex,1}[]
    for line in per_line(text, false)
        pos = CartesianIndex(0, 0)
        inner = CartesianIndex[]
        for item in per_split(line, ',')
            parsed = parse_dir(item)
            pos += parsed
            mi = min(mi, pos)
            ma = max(ma, pos)
            push!(inner, parsed)
        end
        push!(re, inner)
    end
    Input((wires=re, min=mi, max=ma))
end
fload() = inputfile |> slurp |> load
input = fload()

manhatten(input) = mapreduce(j -> abs(input[j]), +, (1,2))

function drawlines(input::Input = fload())
    mi::CartesianIndex = input.min
    rows = input.max[1] - mi[1] + 1
    cols = input.max[2] - mi[2] + 1

    map(input.wires) do wire
        steps = OffsetArray(zeros(Num, rows, cols), mi[1] - 1, mi[2] - 1)
        start = CartesianIndex(0, 0)
        increment = 0

        for move in wire
            stop = start + move
            if start[1] == stop[1]
                same = 1
                diff =  2
            else
                same = 2
                diff =  1
            end
            step = start[diff] < stop[diff] ? 1 : -1
            for i in start[diff]:step:stop[diff]-step
                cursor = CartesianIndex(same == 1 ? start[1] : i, same == 2 ? start[2] : i)
                getindex(steps, cursor) > 0 || setindex!(steps, getindex(steps, cursor) + increment, cursor)
                increment += 1
            end
            start = stop
        end

        crossings = steps .> 0
        (; crossings, steps)
    end
end

function part1(input::Input = fload())
    @chain input begin
        drawlines
        mapreduce(i -> i.crossings, (a,b) -> a .& b, _)
        findall
        minimum(manhatten, _)
    end
end

function part2(input::Input = fload())
    lines = drawlines(input)
    crossings = mapreduce(i -> i.crossings, (a,b) -> a .& b, lines)
    mapreduce(i -> i.steps[crossings], +, lines) |> minimum
end

println("Closest intersection to the origin: ", part1())
println("Earliest intersection after the origin: ", part2())
