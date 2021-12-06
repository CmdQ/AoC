from collections import Counter
from pathlib import Path



with (Path(__file__).parent / "06-fish.txt").open("r") as f:
    input = [int(n) for n in f.readline().split(",")]


def one(input, days):
    input = input.copy()
    for _ in range(days):
        for i in range(len(input)):
            if (reduced := input[i] - 1) == -1:
                input[i] = reduced + 7
                input.append(8)
            else:
                input[i] = reduced
    return len(input)


print(one(input, 80))


def two(input, days):
    states = Counter(input)
    for _ in range(days):
        new = Counter()
        for age, count in states.items():
            if age > 0:
                new[age - 1] += count
            else:
                new[age + 6] += count
                new[8] = count
        states = new
    return sum(states.values())


assert two(input, 256) == 1592918715629
print(two(input, 256))
