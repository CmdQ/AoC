using Utils

using Chain
using Lazy
using Underscores

@Base.kwdef struct Point
    x::Int = 0
    y::Int = 0
end

struct Line
    a::Point
    b::Point
end

horizontal(line::Line) = line.a.x == line.b.x
vertical(line::Line) = line.a.y == line.b.y
axisaligned(line) = horizontal(line) || vertical(line)

inputfile = find_input(@__FILE__)
content = @> inputfile slurp
width = height = 0
input = per_line(content, false) do line
    x1, y1, x2, y2 = @_ line |>
        split(__, " -> ") |>
        map(split(_, ","), __) |>
        Iterators.flatten |>
        map(curry(parse, Int), __)
    global width = max(width, x1, x2)
    global height = max(height, y1, y2)
    Line(Point(x1,y1), Point(x2,y2))
end
height += 1
width += 1

function sirange(start, stop)
    start > stop && return range(start, stop, step=-1)
    range(start, stop)
end

function drawAA(input)
    field = zeros(Int, height, width)
    for line in input
        same = line.a
        if horizontal(line)
            field[sirange(line.a.y, line.b.y), same.x] .+= 1
        elseif vertical(line)
            field[same.y, sirange(line.a.x, line.b.x)] .+= 1
        end
    end
    field
end

function drawdiag!(field, input)
    for line in filter(!axisaligned, input)
        for (x,y) in zip(sirange(line.a.x, line.b.x), sirange(line.a.y, line.b.y))
            field[y, x] += 1
        end
    end
end

field = drawAA(input)
answer1 = count(>=(2), field)
assertequal(answer1, 8350)

drawdiag!(field, input)
answer2 = count(>=(2), field)
assertequal(answer2, 19374)
