from copy import deepcopy
from pathlib import Path
from typing import NamedTuple, Optional


class Problem(NamedTuple):
    draws: list[int]
    boards: list[list[list[int]]]


with (Path(__file__).parent / "04-bingo.txt").open("r") as f:
    draws = [int(i) for i in f.readline().split(",")]
    boards = []
    board = []
    for line in f:
        if not line.strip():
            if board:
                assert len(board) == 5
                boards.append(board)
            board = []
            continue
        board.append([int(i) for i in line.split()])
    if len(board) == 5:
        boards.append(board)
    else:
        raise RuntimeError

problem = Problem(draws, boards)


def winning_board(board):
    for i in range(5):
        if all(e is None for e in board[i]):
            return True
        if all(e is None for e in (board[j][i] for j in range(5))):
            return True
    return False


def score(board, last_draw):
    return sum(board[r][c] or 0 for r in range(5) for c in range(5)) * last_draw


def cross(board, num):
    for r in range(5):
        for c in range(5):
            if board[r][c] == num:
                board[r][c] = None
                return


def one(problem: Problem):
    boards = deepcopy(problem.boards)
    for draw in problem.draws:
        for board in boards:
            cross(board, draw)
            if winning_board(board):
                return score(board, draw)


def two(problem: Problem):
    boards = deepcopy(problem.boards)
    for draw in problem.draws:
        next_round = []
        for board in boards:
            cross(board, draw)
            if not winning_board(board):
                next_round.append(board)
            elif len(boards) == 1:
                return score(board, draw)
        boards = next_round


print(one(problem))
print(two(problem))


def test_score():
    board = [
        [None, None, None, None, None],
        [10, 16, 15, None, 19],
        [18, 8, None, 26, 20],
        [22, None, 13, 6, None],
        [None, None, 12, 3, None],
    ]
    assert score(board, 1) == 188
    assert score(board, 24) == 4512


def test_winning_board():
    board: list[list[Optional[int]]] = [
        [14, 21, 17, 24, 4],
        [10, 16, 15, 9, 19],
        [18, 8, 23, 26, 20],
        [22, 11, 13, 6, 5],
        [2, 0, 12, 3, 7],
    ]
    for num in [7, 4, 9, 5, 11, 17, 23, 2, 0, 14, 21]:
        cross(board, num)
        assert not winning_board(board)
    cross(board, 24)
    assert winning_board(board)

    board[0][3] = 24
    for num in [10, 18]:
        cross(board, num)
        assert not winning_board(board)
    cross(board, 22)
    assert winning_board(board)
