using Underscores
using Utils

function parse_file(f)
    re::Array{Union{Rotate,Move}} = []
    for line in eachline(f)
        number = parse(UInt16, line[2:end])
        d = if line[1] == 'N'
            Move(north, number)
        elseif line[1] == 'E'
            Move(east, number)
        elseif line[1] == 'S'
            Move(south, number)
        elseif line[1] == 'W'
            Move(west, number)
        elseif line[1] == 'L'
            Rotate(left, number)
        elseif line[1] == 'R'
            Rotate(right, number)
        else
            @assert line[1] == 'F'
            Move(forward, number)
        end
        push!(re, d)
    end
    re
end

function load()
    open(joinpath(@__DIR__, "12_ship-movement.txt"), "r") do f
        parse_file(f)
    end
end

@enum LeftRight::UInt16 left=0 right=180 full=360

function Base.:!(lr::LeftRight)
    @assert lr != full
    lr == left ? right : left
end

@enum NESW::UInt16 north=0 east=270 south=180 west=90 forward=1

function Base.:+(dir::NESW, degrees::UInt16)::NESW
    dir == forward && return forward
    return NESW((Integer(dir) + degrees) % Integer(full))
end

struct Pos
    lat::Int
    long::Int
    heading::NESW
end
Pos() = Pos(0, 0, east)
Pos(heading::NESW) = Pos(0, 0, heading)

struct Waypoint
    lat::Int
    long::Int
end

struct PosWithWaypoint
    lat::Int
    long::Int
    waypoint::Waypoint
end
PosWithWaypoint(w::Waypoint) = PosWithWaypoint(0, 0, w)

abssum(pos) = abs(pos.lat) + abs(pos.long)

struct Move
    direction::NESW
    by::Int
end

function Base.:+(pos::Pos, nesw::Move)
    lat = pos.lat
    long = pos.long
    direction = nesw.direction == forward ? pos.heading : nesw.direction
    if direction == north
        lat += nesw.by
    elseif direction == south
        lat -= nesw.by
    elseif direction == east
        long += nesw.by
    elseif direction == west
        long -= nesw.by
    end
    Pos(lat, long, pos.heading)
end

function Base.:+(pos::PosWithWaypoint, nesw::Move)
    by = nesw.by
    if nesw.direction == forward
        PosWithWaypoint(pos.lat + by * pos.waypoint.lat, pos.long + by * pos.waypoint.long, pos.waypoint)
    elseif nesw.direction == north
        PosWithWaypoint(pos.lat, pos.long, Waypoint(pos.waypoint.lat + by, pos.waypoint.long))
    elseif nesw.direction == south
        PosWithWaypoint(pos.lat, pos.long, Waypoint(pos.waypoint.lat - by, pos.waypoint.long))
    elseif nesw.direction == east
        PosWithWaypoint(pos.lat, pos.long, Waypoint(pos.waypoint.lat, pos.waypoint.long + by))
    elseif nesw.direction == west
        PosWithWaypoint(pos.lat, pos.long, Waypoint(pos.waypoint.lat, pos.waypoint.long - by))
    end
end

struct Rotate
    direction::LeftRight
    by::UInt16
end

function Base.:+(heading::NESW, turn::Rotate)
    if turn.by % 180 == 0
        heading + turn.by
    else
        heading + (turn.by + Integer(turn.direction))
    end
end

function Base.:+(pos::Pos, rot::Rotate)
    Pos(pos.lat, pos.long, pos.heading + rot)
end

function Base.:+(pos::PosWithWaypoint, rot::Rotate)
    PosWithWaypoint(pos.lat, pos.long, pos.waypoint + rot)
end

function Base.:+(w::Waypoint, rot::Rotate)
    if rot.by == 180
        Waypoint(-w.lat, -w.long)
    elseif rot.by == 270
        w + Rotate(!rot.direction, 90)
    elseif rot.direction == left
        @assert rot.by == 90
        Waypoint(w.long, -w.lat)
    elseif rot.direction == right
        @assert rot.by == 90
        Waypoint(-w.long, w.lat)
    end
end

function ex(route, init)
    foldl(+, route, init=init) |> abssum
end

ex1(route) = ex(route, Pos(east))
ex2(route) = ex(route, PosWithWaypoint(Waypoint(1, 10)))

route = load()

println("Manhatten distance: ", ex1(route))
println("Manhatten distance by waypoint: ", ex2(route))









using Test

@testset "Rain Risk" begin
    @test length(route) == 783

    @testset "operators rotate" begin
        for start in instances(NESW)
            if start != forward
                angle = Integer(full)
                while angle >= 90
                    times = Integer(full) / angle
                    la, lo = rand(Int, 2)
                    pos = Pos(la, lo, start)
                    for _ in 1:times
                        pos = pos + Rotate(left, angle)
                    end
                    @test pos == Pos(la, lo, start)
                    for _ in 1:times
                        pos = pos + Rotate(right, angle)
                    end
                    @test pos == Pos(la, lo, start)
                    angle ÷= 2
                end
            end
        end

        @test Waypoint(4, 10) + Rotate(right, 90) == Waypoint(-10, 4)
    end

    @testset "operators move" begin
        @test Pos(1, 2, north) + Move(forward, 10) == Pos(11, 2, north)
        @test Pos(1, 2, east) + Move(forward, 10) == Pos(1, 12, east)
        @test Pos(1, 2, south) + Move(forward, 10) == Pos(-9, 2,south)
        @test Pos(1, 2, west) + Move(forward, 10) == Pos(1, -8, west)
    end

    input = """
    F10
    N3
    F7
    R90
    F11
    """

    example = parse_file(IOBuffer(input))

    @testset "example 1" begin
        @test ex1(example) == 25
    end

    @testset "example 2" begin
        @test ex2(example) == 286
    end

    @testset "results" begin
        @test ex1(route) == 1152
        @test ex2(route) == 58637
    end
end