using Utils

using Chain
using Lazy
using Underscores

function load()
    inputfile = find_input(@__FILE__)
    open(inputfile, "r") do f
        draws, boardstr... = split_blocks(f)
        boards = map(boardstr) do block
            @chain block begin
                split("\n")
                map(line -> parse.(Int, split(line)), _)
                reduce(hcat, _)
                transpose
            end
        end
        (draws=parse.(Int, split(draws, ",")), boards=boards)
    end
end
input = load()

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

function one(input)
    boards = deepcopy(input.boards)
    for draw in input.draws, board in boards
        cross(board, draw)
        winner(board) && return score(board, draw)
    end
end
@assert one(input) == 8136

function two(input)
    boards::Vector{Matrix{Int64}} = deepcopy(input.boards)
    for draw in input.draws
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
@assert two(input) == 12738

println(one(input))
println(two(input))
