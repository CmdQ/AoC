using ProblemParser
using Utils

using Accessors
using Chain
using DataStructures
using Memoize
using StaticArrays

import IterTools

struct Player
    pos::Int8
    score::Int16
end

const file = find_input(@__FILE__)
const input = MVector{2,Player}(undef)
for m in eachmatch(r"Player ([12]) starting position: (\d+)", slurp(file))
    input[parse(Int, m[1])] = Player(parse(Int16, m[2]), 0)
end

function advance(player::Player, steps)
    pos = mod1(player.pos + steps, 10)
    Player(pos, player.score + pos)
end

function turn(input, die, which)::Int8
    steps = 0
    for _ in 1:3
        die += 1
        die > 100 && (die = 1)
        steps += die
    end
    input[which] = advance(input[which], steps)
    die
end

score(input, rolls, which) = input[3 - which].score * rolls

function part1(input)
    input = deepcopy(input)
    die::Int8 = 0
    rolls = 0
    while true
        die = turn(input, die, 1)
        rolls += 3
        input[1].score >= 1000 && return score(input, rolls, 1)
        die = turn(input, die, 2)
        rolls += 3
        input[2].score >= 1000 && return score(input, rolls, 2)
    end
end

assertequal(part1(input), 1_073_709)

const threesums = @chain [1:3] begin
    repeat(_, 3)
    IterTools.product(_...)
    collect
    reshape(:)
    map(sum, _)
    sort
end

@memoize function part2(input::Tuple{Player,Player}, which)::Dict{Int8, Int}
    wins = DefaultDict{Int8,Int}(0)
    for s in threesums
        active = advance(input[which], s)

        if active.score >= 21
            wins[which] += + 1
        else
            updated = @set input[which] = active
            other = part2(updated, 3 - which)
            mergewith!(+, wins, other)
        end
    end
    wins
end

part2(input::AbstractVector{Player}) = part2(Tuple(input), 1) |> values |> maximum

assertequal(part2(input), 148_747_830_493_442)
