using Underscores
using Utils

function load()
    open(aoc"03_tree-map", "r") do f
        permutedims(reduce(hcat, collect.(eachline(f))))
    end
end

function count_trees(map, right, down)
    length, wrap = size(map)
    col, row = 1, 1
    trees = 0
    while row <= length
        if map[row, mod1(col, wrap)] == '#'
            trees += 1
        end
        col += right
        row += down
    end
    trees
end

function tree_product(map, slopes)
    @_ prod(count_trees(map, _...), slopes)
end

trees = load()
slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]

println("Trees for 3 and 1: $(count_trees(trees, 3, 1))")
println("Product of tree counts for $slopes: $(tree_product(trees, slopes))")






using Test

@testset "Toboggan Trajectory" begin
    @test size(trees, 1) == 323
    @test size(trees, 2) == 31

    @testset "example input" begin
        example_input = """
            ..##.......
            #...#...#..
            .#....#..#.
            ..#.#...#.#
            .#...##..#.
            ..#.##.....
            .#.#.#....#
            .#........#
            #.##...#...
            #...##....#
            .#..#...#.#
            """
        example = permutedims(reduce(hcat, collect.(eachline(IOBuffer(example_input)))))

        @test size(example) == (11, 11)

        @testset "part one" begin
            @test count_trees(example, 3, 1) == 7
        end

        @testset "part two" begin
            @test tree_product(example, slopes) == 336
        end
    end

end