using Utils
using ProblemParser

using Chain
using Dictionaries

import IterTools

module Data
using Dictionaries
struct Point3D
    x::Int32
    y::Int32
    z::Int32
end
Point3D() = Point3D(0, 0, 0)
struct Sparse3D
    trues::Indices{Point3D}
end
Sparse3D(points::Vector{Point3D}) = points |> distinct |> Sparse3D
struct AllOrientations
    cube::Sparse3D
end
end
Point3D=Data.Point3D
Sparse3D=Data.Sparse3D
AllOrientations=Data.AllOrientations

Base.:(==)(lhs::Sparse3D, rhs::Sparse3D) = lhs.trues == rhs.trues

rot90(cube::Sparse3D, ::Union{Val{1},Val{:x}})::Sparse3D = map(cube.trues) do p
    Point3D(p.x, -p.z, p.y)
end |> Indices |> Sparse3D

rot90(cube::Sparse3D, ::Union{Val{2},Val{:y}})::Sparse3D = map(cube.trues) do p
    Point3D(p.z, p.y, -p.x)
end |> Indices |> Sparse3D

rot90(cube::Sparse3D, ::Union{Val{3},Val{:z}})::Sparse3D = map(cube.trues) do p
    Point3D(-p.y, p.x, p.z)
end |> Indices |> Sparse3D

mirror(cube::Sparse3D)::Sparse3D = map(cube.trues) do p
    Point3D(-p.x, -p.y, -p.z)
end |> Indices |> Sparse3D

Base.iterate(start::AllOrientations) = start.cube, (start.cube,1)

function Base.iterate(::AllOrientations, (cube, state))
    state > lastindex(rots) && return nothing
    transformed = rots[state](cube)
    transformed, (transformed,state + 1)
end

Base.length(::AllOrientations) = 24
Base.eltype(::AllOrientations) = Sparse3D

# Build all 24 orientations by this series of 24 transformations.
rots = Function[curry2nd(rot90, Val(d)) for d in [:x, :y, :z] for _ in 1:3]
push!(rots, curry2nd(rot90, Val(:x)), curry2nd(rot90, Val(:y)))
push!(rots, mirror)
append!(rots, rots[begin:end-1])
# Make sure it delivers 24 distinct points.
@assert length(Set(c for c in AllOrientations(Sparse3D([Point3D(1,2,3)])))) == 24

using Test
@testset begin
    sample = Sparse3D([Point3D(3,0,0), Point3D(0,5,0), Point3D(0,0,2)])

    @testset "rotate z" begin
        rotations = @chain sample begin
            IterTools.iterated(curry2nd(rot90, Val(:z)), _)
            Iterators.take(5)
            map(s -> s.trues, _)
            collect
        end
        print(rotations)

        @test rotations == [
            sample.trues
            Indices([Point3D(0,3,0), Point3D(-5,0,0), Point3D(0,0,2)])
            Indices([Point3D(-3,0,0), Point3D(0,-5,0), Point3D(0,0,2)])
            Indices([Point3D(0,-3,0), Point3D(5,0,0), Point3D(0,0,2)])
            sample.trues
        ]
    end
end

file = find_input(@__FILE__)#,"example.txt")
load(file) = @chain file begin
    slurp
    parse(Blocks(FirstRest(Lines(), Extract(), Lines(Split(',', Convert(Int32))))), _)
    map(_) do (i, points)
        i, map(tup3 -> Point3D(tup3...), points) |> Sparse3D
    end
end
input = load(file)

manhatten(lhs::Point3D, rhs::Point3D) = abs(lhs.x - rhs.x) + abs(lhs.y - rhs.y) + abs(lhs.z - rhs.z)

fingerprint(cubes::Sparse3D) = Set(manhatten(a, b) for a in cubes.trues for b in cubes.trues if a != b)

function part1(input)
    threshold = 12*11÷2
    base, rest... = input
    basefingerprint = fingerprint(base[2])
    while !isempty(rest)
        found = false
        for idx in eachindex(rest)
            (i, other) = rest[idx]
            println("check $i")
            fp = fingerprint(other)
            intersect!(fp, basefingerprint)
            if length(fp) >= threshold
                println("match for $i")
                deleteat!(rest, idx)
                found = true
                break
            end
        end
        !found && error("no match found in this round")
    end
end
part1(input)

assertequal(part1(input))

part2() = count(Iterators.product(1:input.ur.x, -99:99)) do tup
    any(occursin(input), Point(tup...))
end

assertequal(part2(), 1928)



"""
--- scanner 0 ---
404;-588;-901
528;-643;409
-838;591;734
390;-675;-793
-537;-823;-458
-485;-357;347
-345;-311;381
-661;-816;-575
-876;649;763
-618;-824;-621
553;345;-567
474;580;667
-447;-329;318
-584;868;-557
544;-627;-890
564;392;-477
455;729;728
-892;524;684
-689;845;-530
423;-701;434
7;-33;-71
630;319;-379
443;580;662
-789;900;-551
459;-707;401

--- scanner 1 ---
686;422;578
605;423;415
515;917;-361
-336;658;858
95;138;22
-476;619;847
-340;-569;-846
567;-361;727
-460;603;-452
669;-402;600
729;430;532
-500;-761;534
-322;571;750
-466;-666;-811
-429;-592;574
-355;545;-477
703;-491;-529
-328;-685;520
413;935;-424
-391;539;-444
586;-435;557
-364;-763;-893
807;-499;-711
755;-354;-619
553;889;-390

-618;-824;-621
-537;-823;-458
-447;-329;318
404;-588;-901
544;-627;-890
528;-643;409
-661;-816;-575
390;-675;-793
423;-701;434
-345;-311;381
459;-707;401
-485;-357;347
"""