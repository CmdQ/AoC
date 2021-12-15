using Utils

using Chain

inputfile = find_input(@__FILE__)

function load(fname)
    dotlist = Tuple{Int,Int}[]
    folds = Tuple{Symbol,Int}[]
    maxx = maxy = 0
    open(fname) do io
        for line in eachline(io)
            line == "" && continue
            m = match(r"fold along ([xy])=(\d+)", line)
            if m === nothing
                x,y = map(curry(parse, Int), split(line, ","))
                maxx = max(maxx, x)
                maxy = max(maxy, y)
                push!(dotlist, (y,x))
            else
                push!(folds, (Symbol(m[1]), parse(Int, m[2])))
            end
        end
    end
    dots = falses(maxy + 1, maxx + 1) |> zerobased
    for d in dotlist
        dots[d...] = true
    end
    (dots=dots, folds=folds)
end
input = load(inputfile)

function part2(input, onlyone=false)
    dots = copy(input.dots)
    for fold in input.folds
        if fold[1] == :x
            dots = transpose(dots)
        end
        num = fold[2]
        foldin = size(dots, 1) - num - 1
        dots[num - foldin:num - 1,:] .|= @view dots[end:-1:num + 1,:]
        dots = dots[begin:num - 1,:] |> zerobased
        if fold[1] == :x
            dots = transpose(dots)
        end
        onlyone && return "$(count(dots))"
    end
    @chain dots begin
        map(c -> c ? '8' : ' ', _)
        eachrow
        map(String, _)
        join('\n')
    end
end

part1 = curry2nd(part2, true)
assertequal(part1(input), "678")
println('\n', part2(input))
