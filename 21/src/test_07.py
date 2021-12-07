from pathlib import Path


with (Path(__file__).parent / "07-crabs.txt").open("r") as f:
    input = [int(n) for n in f.readline().split(",")]


def one(input):
    input = sorted(input)
    median = input[len(input) // 2]
    return sum(abs(median - pos) for pos in input)

print(one(input))

def triangular(n):
    return n*(n+1)//2

def two(input):
    average = int(sum(input)/len(input))
    return sum(triangular(abs(average - pos)) for pos in input)


print(two(input))
