using Chain
using Underscores
using Utils

@enum Seat::Int8 floor=Int('.') empty=Int('L') occupied=Int('#') void=Int('?')

function parse_line(line::String)::Array{Seat}
    @chain line begin
        collect
        map(Seat ∘ Int, _)
    end
end

function embed(m)
    a, b = size(m)
    re = fill(void, (a+2, b+2))
    re[2:end-1, 2:end-1] = m
    re
end

function parse_file(f)
    m = @chain f begin
        eachline
        map(parse_line, _)
        foldl(hcat, _)
        permutedims
    end
    embed(m)
end

function load()
    open(aoc"11_seats", "r") do f
        parse_file(f)
    end
end

is_occupied(c) = c == occupied

function step(counter, grid, tolerance)
    a, b = axes(grid)
    prev = copy(grid)
    changed = false

    for i in firstindex(a)+1:lastindex(a)-1, j in firstindex(b)+1:lastindex(b)-1
        co = counter(prev, i, j)
        if prev[i, j] == empty && co == 0
            grid[i, j] = occupied
            changed = true
        elseif is_occupied(prev[i, j]) && co >= tolerance
            grid[i, j] = empty
            changed = true
        end
    end

    changed
end

block_count(grid, i, j) = count(is_occupied, grid[i-1:i+1, j-1:j+1]) - Int(is_occupied(grid[i, j]))

function ex(counter, grid, tolerance)
    grid = copy(grid)

    loop = true
    while loop
        loop = step(counter, grid, tolerance)
    end

    count(is_occupied, grid)
end

ex1(grid) = ex(block_count, grid, 4)

function sight_count(grid, i, j)
    count = 0
    for row in -1:1, col in -1:1
        if (row | col) != 0 # Don't count the center.
            rr = i + row
            cc = j + col
            # No need to check indices, because there's definitely a void boundary.
            while grid[rr, cc] == floor
                rr += row
                cc += col
            end
            count += is_occupied(grid[rr, cc]) |> Int
        end
    end
    count
end

ex2(grid) = ex(sight_count, grid, 5)

grid = load()

println("Stable seating occupied: ", ex1(grid))
println("Number of combinations: ", ex2(grid))








using Test

@testset "Adapter Array" begin
    input = """
        L.LL.LL.LL
        LLLLLLL.LL
        L.L.L..L..
        LLLL.LL.LL
        L.LL.LL.LL
        L.LLLLL.LL
        ..L.L.....
        LLLLLLLLLL
        L.LLLLLL.L
        L.LLLLL.LL
        """


    example = parse_file(IOBuffer(input))

    @testset "example 1" begin
        example = copy(example)
        mini = parse_file(IOBuffer("L.\n.L"))
        @test count(is_occupied, mini) == 0
        step(block_count, mini, 4)
        @test count(is_occupied, mini) == 2
        @test mini[2:end-1, 2:end-1] == [occupied floor; floor occupied]
        @test ex1(example) == 37
    end

    @testset "example 2" begin
        see_eight = """
        .......#.
        ...#.....
        .#.......
        .........
        ..#L....#
        ....#....
        .........
        #........
        ...#.....
        """
        see_eight = see_eight |> IOBuffer |> parse_file

        @test see_eight[5+1, 4+1] == empty
        @test sight_count(see_eight, 5+1, 4+1) == 8

        see_one = """
        .............
        .L.L.#.#.#.#.
        .............
        """
        see_one = see_one |> IOBuffer |> parse_file

        @test see_one[2+1, 2+1] == empty
        @test see_one[2+1, 4+1] == empty
        @test sight_count(see_one, 2+1, 2+1) == 0
        @test sight_count(see_one, 2+1, 4+1) == 1

        see_none = """
        .##.##.
        #.#.#.#
        ##...##
        ...L...
        ##...##
        #.#.#.#
        .##.##.
        """
        see_none = see_none |> IOBuffer |> parse_file

        @test see_none[4+1, 4+1] == empty
        @test sight_count(see_none, 4+1, 4+1) == 0

        example = copy(example)
        @test ex2(example) == 26
    end

    @testset "results" begin
        @test ex1(grid) == 2204
        @test ex2(grid) == 1986
    end
end