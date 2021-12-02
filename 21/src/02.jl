using Utils

using Accessors
using CompositeStructs
using Underscores

const FORWARD = "forward"
const UP = "up"
const DOWN = "down"

inputfile = find_input(@__FILE__)
input = @_ inputfile |>
    slurp |>
    per_line(__, false) |>
    map(split(_), __) |>
    map((_[1], parse(Int, _[2])), __)

@Base.kwdef struct Position
    position::Int = 0
    depth::Int = 0
end

function Base.:+(pos::Position, directions::Tuple{AbstractString, Int})
    command, amount = directions
    if command == FORWARD
        @set pos.position += amount
    elseif command == DOWN
        @set pos.depth += amount
    elseif command == UP
        @set pos.depth -= amount
    end
end

@composite @Base.kwdef struct AimingPosition
    Position...
    aim::Int = 0
end

function Base.:+(pos::AimingPosition, directions::Tuple{AbstractString, Int})
    command, amount = directions
    if command == FORWARD
        AimingPosition(pos.position + amount, pos.depth + pos.aim * amount, pos.aim)
    elseif command == DOWN
        @set pos.aim += amount
    elseif command == UP
        @set pos.aim -= amount
    end
end

function solve(input, type)
    final = sum(input; init=type())
    final.position * final.depth
end

one(input) = solve(input, Position)
@assert one(input) == 2039912

two(input) = solve(input, AimingPosition)
@assert two(input) == 1942068080

for f in [one, two]
    input |> f |> println
end
