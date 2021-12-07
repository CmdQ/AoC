using Utils

using Accessors
using CompositeStructs
using Underscores

inputfile = find_input(@__FILE__)
input = @_ inputfile |>
    slurp |>
    per_line(((cmd, num) = split(_); (Symbol(cmd), parse(Int, num))), __, false)

@Base.kwdef struct Position
    position::Int = 0
    depth::Int = 0
end

function Base.:+(pos::Position, directions::Tuple{Symbol, Int})
    command, amount = directions
    if command == :forward
        @set pos.position += amount
    elseif command == :down
        @set pos.depth += amount
    elseif command == :up
        @set pos.depth -= amount
    end
end

@composite @Base.kwdef struct AimingPosition
    Position...
    aim::Int = 0
end

function Base.:+(pos::AimingPosition, directions::Tuple{Symbol, Int})
    command, amount = directions
    if command == :forward
        AimingPosition(pos.position + amount, pos.depth + pos.aim * amount, pos.aim)
    elseif command == :down
        @set pos.aim += amount
    elseif command == :up
        @set pos.aim -= amount
    end
end

function solve(input, type)
    final = sum(input; init=type())
    final.position * final.depth
end

part1(input) = solve(input, Position)
@assert part1(input) == 2039912

part2(input) = solve(input, AimingPosition)
@assert part2(input) == 1942068080

for f in [part1, part2]
    input |> f |> println
end
