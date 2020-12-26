using  Utils

const HALF = 16

function parse_file(f)
    size = fill(2 * HALF, 3)
    re = zeros(Bool, size...)

    for (row, line) in enumerate(eachline(f))
        for (col, c) in enumerate(line)
            re[row+HALF,col+HALF,1+HALF] = c == '#'
        end
    end
    re
end


function load()
    open(aoc"17", "r") do f
        parse_file(f)
    end
end

function neighbors(cubes, r, c, s)
    count(view(cubes, r-1:r+1, c-1:c+1, s-1:s+1)) - Int(cubes[r,c,s])
end

function neighbors(cubes, r, c, s, d)
    count(view(cubes, r-1:r+1, c-1:c+1, s-1:s+1, d-1:d+1)) - Int(cubes[r,c,s,d])
end

function step(cubes::AbstractArray{Bool,3})
    same_dim = axes(cubes, 1)
    range = firstindex(same_dim)+1:lastindex(same_dim)-1

    prev = copy(cubes)
    for slice in range
        for col in range
            for row in range
                ns = neighbors(prev, row, col, slice)
                if prev[row,col,slice] && !(ns == 2 || ns == 3)
                    cubes[row,col,slice] = false
                elseif !prev[row,col,slice] && ns == 3
                    cubes[row,col,slice] = true
                end
            end
        end
    end
end

function step(cubes::AbstractArray{Bool,4})
    same_dim = axes(cubes, 1)
    range = firstindex(same_dim)+1:lastindex(same_dim)-1

    prev = copy(cubes)
    for dimension in range
        for slice in range
            for col in range
                for row in range
                    ns = neighbors(prev, row, col, slice, dimension)
                    if prev[row,col,slice,dimension] && !(ns == 2 || ns == 3)
                        cubes[row,col,slice,dimension] = false
                    elseif !prev[row,col,slice,dimension] && ns == 3
                        cubes[row,col,slice,dimension] = true
                    end
                end
            end
        end
    end
end

function ex1(cubes, to=6)
    cubes = copy(cubes)
    for i in 1:to
        step(cubes)
    end
    count(cubes)
end

function ex2(cubes, to=6)
    more = zeros(Bool, size(cubes)..., 2 * HALF)
    more[:,:,:,1+HALF] = cubes
    ex1(more, to)
end

cubes = load()

println("Alive after 6 rounds: ", ex1(cubes))
println("Alive after 6 hypercube rounds: ", ex2(cubes))











using Test

@testset "Conway Cubes" begin
    input = """
    .#.
    ..#
    ###
    """

    cubes = parse_file(IOBuffer(input))

    @testset "example 1" begin
        @test ex1(cubes) == 112
    end

    @testset "example 2" begin
        @test ex2(cubes, 0) == 5
        @test ex2(cubes, 1) == 29
        @test ex2(cubes) == 848
    end

    @testset "results" begin
    end
end