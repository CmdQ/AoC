from pathlib import Path
from typing import NamedTuple


class Point(NamedTuple):
    x: int
    y: int


with (Path(__file__).parent / "05-vents.txt").open("r") as f:
    input = []
    width = height = 0
    for line in f:
        parsed = [Point(*map(int, p.split(","))) for p in line.split(" -> ")]
        width = max(width, *[parsed[i].x for i in range(2)])
        height = max(height, *[parsed[i].y for i in range(2)])
        input.append(tuple(parsed))
width += 1
height += 1


def sirange(start, stop):
    if start > stop:
        yield from range(start, stop - 1, -1)
    yield from range(start, stop + 1)


def draw_field(input, diagonal=False):
    field = [[0] * width for _ in range(height)]
    for p in input:
        if p[0].x == p[1].x:
            for y in sirange(p[0].y, p[1].y):
                field[y][p[0].x] += 1
        elif p[0].y == p[1].y:
            for x in sirange(p[0].x, p[1].x):
                field[p[0].y][x] += 1
        elif diagonal:
            for x, y in zip(sirange(p[0].x, p[1].x), sirange(p[0].y, p[1].y)):
                field[y][x] += 1
    return sum(field[r][c] >= 2 for r in range(height) for c in range(width))


def one(input):
    return draw_field(input)


def two(input):
    return draw_field(input, True)


print(one(input))
print(two(input))
