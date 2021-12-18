using ProblemParser
using Utils

using Chain
using Lazy
using Underscores

file = find_input(@__FILE__)
input = parse(FirstRest(Blocks(),
        Split(",", Convert(Int8)),
        Blocks(Rectangular(Lines(Split(Convert(Int8)))))
    ), file |> slurp)

function cross(board, num)
    for i in eachindex(board)
        val = board[i]
        if val == num
            board[i] = -1
            return
        end
    end
end

function winner(board)
    along(rowcol) = any(curry(all, ==(-1)), rowcol(board))
    along(eachcol) || along(eachrow)
end

score(board, num) = sum(filter(>=(0), board)) * num

function part1(input)
    boards = deepcopy(input[2])
    for draw in input[1], board in boards
        cross(board, draw)
        winner(board) && return score(board, draw)
    end
end
assertequal(part1(input), 8136)

function part2(input)
    boards::Vector{Matrix{Int64}} = deepcopy(input[2])
    for draw in input[1]
        next::typeof(boards) = []
        for board in boards
            cross(board, draw)
            if !winner(board)
                push!(next, board)
            elseif length(boards) == 1
                return score(board, draw)
            end
        end
        boards = next
    end
end
assertequal(part2(input), 12738)
