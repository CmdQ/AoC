using Utils

using Accessors
using Chain

const FORWARD = "forward"
const UP = "up"
const DOWN = "down"

inputfile = find_input(@__FILE__)
input = @chain inputfile begin
    slurp
    per_line(false)
    map(line -> split(line), _)
    map(((n, s),) -> (n, parse(Int, s)), _)
end

struct Position
    position::Int
    depth::Int
end
function Position(pos=0, depth=0)
    Position(pos, depth)
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

struct AimingPosition
    position::Int
    depth::Int
    aim::Int
end
function AimingPosition(pos=0, depth=0, aim=0)
    AimingPosition(pos, depth, aim)
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
