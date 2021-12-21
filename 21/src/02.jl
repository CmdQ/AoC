using ProblemParser
using Utils

using Accessors
using CompositeStructs
using Underscores

const file = find_input(@__FILE__)
const input = @_ file |> slurp |> parse(Lines(FirstRest(Split(), Apply(Symbol), Convert())), __)

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
assertequal(part1(input), 2039912)

part2(input) = solve(input, AimingPosition)
assertequal(part2(input), 1942068080)
