using Utils
using Underscores
using Chain

const INNER_DIM = 10
const OUTER_DIM = 12
const HEADER = "Tile "

struct Tile
    id::Int
    pix::Matrix{Bool}
end    

function parse_file(f)
    tiles = split(f)

    re = Tile[]
    for tile in tiles
        id = 0
        pixels = falses(INNER_DIM, INNER_DIM)
        for (i,line) in enumerate(eachline(IOBuffer(tile)))
            if i == 1
                id = parse(Int, line[length(HEADER):end-1])
            else
                pixels[i-1,:] = @_ map(_ == '#', collect(line))
            end
        end
        push!(re, Tile(id, pixels))
    end
    re
end

function load()
    open(aoc"20", "r") do f
        parse_file(f)
    end
end

tiles = load()

horizontal = rotr90 ∘ permutedims
vertical = rotl90 ∘ permutedims
const MIRRORING = [identity, horizontal, vertical]
const ROTATING = [identity, rotl90, rotr90, rot180]
all_transformations = @_ Iterators.product(MIRRORING, ROTATING) |> map(_[1] ∘ _[2], __)

function assemble(tiles)
    len = length(tiles)

    neighbors = falses(fill(len, 2)...)
    function neighborsofin(who, allowed::Set{UInt8})
        ok = typeof(allowed)()
        for (idx, neighbor) in enumerate(neighbors[:,who])
            neighbor && idx in allowed && push!(ok, idx)
        end
        ok
    end

    function connect(left, right)
        neighbors[left, right] = true
        neighbors[right, left] = true
    end

    # Find all connections.
    for left in 1:len
        l = tiles[left].pix
        for right in left+1:len
            for rot in all_transformations
                r = rot(tiles[right].pix)
                
                if l[INNER_DIM,:] == r[1,:]
                    connect(left, right)
                elseif l[1,:] == r[INNER_DIM,:]
                    connect(left, right)
                elseif l[:,INNER_DIM] == r[:,1]
                    connect(left, right)
                elseif l[:,1] == r[:,INNER_DIM]
                    connect(left, right)
                end
            end
        end
    end

    # Sort into categories.
    corners = Set{UInt8}()
    edges = Set{UInt8}()
    inner = Set{UInt8}()
    for i in 1:len
        ones = count(neighbors[:,i])
        to = if ones == 2
            corners
        elseif ones == 3
            edges
        else
            inner
        end
        push!(to, i)
    end

    @assert length(corners) == 4
    @assert (length(edges) / 4 + 2)^2 == len == OUTER_DIM^2
    
    function deduce(known, from)
        pop!(from, Iterators.only(neighborsofin(known, from)))
    end

    image = Matrix{Int}(undef, OUTER_DIM, OUTER_DIM)
    # Arbitrarily fix upper left OBDA.
    image[1,1] = pop!(corners)
    # Also the choice of these two.
    first2edges = neighborsofin(image[1,1], edges)
    image[1,2] = pop!(first2edges)
    image[2,1] = pop!(first2edges)
    delete!(edges, image[1,2])
    delete!(edges, image[2,1])
    
    # Deduce left and top line.
    for i in 3:OUTER_DIM-1
        image[1,i] = deduce(image[1,i-1], edges)
        image[i,1] = deduce(image[i-1,1], edges)
    end

    # The remaining corners now become clear.
    image[1,OUTER_DIM] = deduce(image[1,OUTER_DIM-1], corners)
    image[OUTER_DIM,1] = deduce(image[OUTER_DIM-1,1], corners)
    image[OUTER_DIM,OUTER_DIM] = Iterators.only(corners)

    image[OUTER_DIM,2] = deduce(image[OUTER_DIM,1], edges)
    image[2,OUTER_DIM] = deduce(image[1,OUTER_DIM], edges)
    for i in 3:OUTER_DIM-1
        image[OUTER_DIM,i] = deduce(image[OUTER_DIM,i-1], edges)
        image[i,OUTER_DIM] = deduce(image[i-1,OUTER_DIM], edges)
    end
    # All edges used.
    @assert isempty(edges)

    # Fill the inner tiles.
    for col in 2:OUTER_DIM-1, row in 2:OUTER_DIM-1
        ns = neighborsofin(image[row-1,col], inner)
        intersect!(ns, neighborsofin(image[row,col-1], inner))
        image[row,col] = pop!(inner, Iterators.only(ns))
    end
    # All inner tiles used.
    @assert isempty(inner)

    # And make a Tile matrix from the index matrix.
    reshape(map(idx -> tiles[idx], image), size(image))
end

assembled = assemble(tiles)

function orient(image::Matrix{Tile})
    pixels = Matrix{Matrix{Bool}}(undef, OUTER_DIM, OUTER_DIM)

    # The first three have to be transformed together.
    for c in all_transformations, a in all_transformations, b in all_transformations
        upper = c(image[1,1].pix)
        lower = a(image[2,1].pix)
        right = b(image[1,2].pix)
        if upper[INNER_DIM,:] == lower[1,:] && upper[:,INNER_DIM] == right[:,1]
            pixels[1,1] = upper
            pixels[2,1] = lower
            pixels[1,2] = right
            break
        end
    end

    # After that, it should be easy sailing for the rest of the row...
    for row in 3:OUTER_DIM
        prev_row = pixels[row-1,1][INNER_DIM,:]
        for t in all_transformations
            lower = t(image[row,1].pix)
            if lower[1,:] == prev_row
                pixels[row,1] = lower
                break
            end
        end
    end

    # ... and column.
    for col in 3:OUTER_DIM
        prev_col = pixels[1,col-1][:,INNER_DIM]
        for t in all_transformations
            right = t(image[1,col].pix)
            if right[:,1] == prev_col
                pixels[1,col] = right
                break
            end
        end
    end

    # Now we can always count on an upper and left neighbor.
    for col in 2:OUTER_DIM, row in 2:OUTER_DIM
        prev_row = pixels[row-1,col][INNER_DIM,:]
        prev_col = pixels[row,col-1][:,INNER_DIM]
        for t in all_transformations
            lower_right = t(image[row,col].pix)
            if lower_right[1,:] == prev_row && lower_right[:,1] == prev_col
                pixels[row,col] = lower_right
                break
            end
        end
    end

    # Lastly, pack it into a smaller image without borders.
    side = OUTER_DIM * (INNER_DIM - 2)
    re = falses(fill(side, 2)...)
    bcol = 1
    for col in 1:OUTER_DIM
        brow = 1
        for row in 1:OUTER_DIM
            re[brow:brow+INNER_DIM-3,bcol:bcol+INNER_DIM-3] = pixels[row,col][2:end-1,2:end-1]
            brow += INNER_DIM - 2
        end
        bcol += INNER_DIM - 2
    end
    re
end

oriented = orient(assembled)

const MONSTER = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   ",
]

monster = @chain MONSTER begin
    map(line -> [c == '#' for c in line], _)
    reduce(hcat, _)
    permutedims
    BitArray
end

function search(image::BitArray{2})
    rm, cm = size(monster)
    ri, ci = size(image)
    local stanced::BitArray{2}
    
    for t in all_transformations
        transd = t(image)
        stanced = copy(transd)

        for col in 1:ci-cm+1, row in 2:ri-1
            patch = transd[row-1:row+1,col:col+cm-1]
            if patch .& monster == monster
                # Found one, so stance it out.
                stanced[row-1:row+1,col:col+cm-1] = patch .!= monster
            end
        end

        stanced != transd && break
    end

    stanced
end

function ex1(tiles::Matrix{Tile})
    s = axes(tiles, 1)
    @chain [firstindex(s), lastindex(s)] begin
        # Twice that combination...
        fill(2)
        # ... then the combinatoric product of them...
        Iterators.product(_...)
        # ... and the multiplication of the IDs.
        prod(((r,c),) -> tiles[r,c].id, _)
    end
end

function ex2(oriented)
    oriented |> search |> count
end

println("Product of corner tiles: ", ex1(assembled))
println("Roughness of the sea: ", ex2(oriented))







using Test

@testset "Jurassic Jigsaw" begin
    @testset "results" begin
        @test ex1(assembled) == 15003787688423
        @test ex2(oriented) == 1705
    end
end
