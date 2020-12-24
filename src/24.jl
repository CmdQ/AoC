using OffsetArrays
using Chain
using Utils

function parse_file(f)
    collect(eachline(f))
end

function load()
    open(aoc"24", "r") do f
        parse_file(f)
    end
end

problem = load()

function ex1(problem)
    dim = 128 | 1
    @assert dim % 2 != 0 "Later code expects odd here."

    black = falses(2dim, 2dim)
    black = OffsetMatrix(black, 1-dim:dim, 1-dim:dim)
    for line in problem
        cur = 1
        c = r = 0
        while cur <= length(line)
            if line[cur] == 'w'
                c -= 2
            elseif line[cur] == 'e'
                c += 2
            else
                if line[cur] == 'n'
                    r -= 1
                elseif line[cur] == 's'
                    r += 1
                else
                    error("shouldn't get here (n or s)")
                end
                cur += 1
                if line[cur] == 'w'
                    c -= 1
                elseif line[cur] == 'e'
                    c += 1
                else
                    error("shouldn't get here (w or e)")
                end
            end
            cur += 1
        end
        @assert abs(r) % 2 == abs(c) % 2 "row and columns need to have the same LSB"
        black[r, c] = !black[r, c]
    end

    (count = count(values(black)), field = black)
end

function black_neighbors(field, r, c)
    @assert abs(r) % 2 == abs(c) % 2 "row and columns need to have the same LSB"
    coords = [
        (-1, -1),
        (-1, 1),
        (0, -2),
        (0, 2),
        (1, -1),
        (1, 1),
    ]
    @chain coords begin
        map(tup -> (r + tup[1], c + tup[2]), _)
        map(((rr, cc),) -> field[rr,cc], _)
        count
    end
end

function step(field)
    prev = copy(field)
    axr, axc = axes(prev)
    for r in firstindex(axr)+1:lastindex(axr)-1
        if r % 2 == 0
            range = firstindex(axc)+2:2:lastindex(axc)-2
            @assert 0 in range
        else
            range = firstindex(axc)+3:2:lastindex(axc)-3
            @assert 1 in range
        end
        for c in range
            ns = black_neighbors(prev, r, c)
            if prev[r,c] && (ns == 0 || ns > 2)
                field[r,c] = false
            elseif !prev[r,c] && ns == 2
                field[r,c] = true
            end
        end
    end
end

function ex2(field)
    for i in 1:100
        step(field)
    end
    count(field)
end

answer = ex1(problem)
println("Black side up initially: ", answer.count)
println("Black side up after 100 days: ", ex2(answer.field))







using Test

@testset "Lobby Layout" begin
    @testset "example 1" begin
        input1 = """
        sesenwnenenewseeswwswswwnenewsewsw
        neeenesenwnwwswnenewnwwsewnenwseswesw
        seswneswswsenwwnwse
        nwnwneseeswswnenewneswwnewseswneseene
        swweswneswnenwsewnwneneseenw
        eesenwseswswnenwswnwnwsewwnwsene
        sewnenenenesenwsewnenwwwse
        wenwwweseeeweswwwnwwe
        wsweesenenewnwwnwsenewsenwwsesesenwne
        neeswseenwwswnwswswnw
        nenwswwsewswnenenewsenwsenwnesesenew
        enewnwewneswsewnwswenweswnenwsenwsw
        sweneswneswneneenwnewenewwneswswnese
        swwesenesewenwneswnwwneseswwne
        enesenwswwswneneswsenwnewswseenwsese
        wnwnesenesenenwwnenwsewesewsesesew
        nenewswnwewswnenesenwnesewesw
        eneswnwswnwsenenwnwnwwseeswneewsenese
        neswnwewnwnwseenwseesewsenwsweewe
        wseweeenwnesenwwwswnew
        """
        
        example1 = parse_file(IOBuffer(input1))

        answer = ex1(example1)
        @test ex1(example1).count == 10
        @test ex2(answer.field) == 2208
    end

    @testset "results" begin
        answer = ex1(problem)
        @test answer.count == 332
        @test ex2(answer.field) == 3900
    end
end
