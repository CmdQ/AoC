using Utils

using Chain

struct Point
    x::Int
    y::Int
end
Point() = Point(0, 0)

struct Area
    ll::Point
    ur::Point
end

struct Shot
    loc::Point
    vel::Point
end
Shot(p) = Shot(Point(), p)

const file = find_input(@__FILE__)
function load(file)
    content = read(file, String)
    nums = map(r -> parse(Int, content[r]), findall(r"-?\d+", content))
    Area(Point(nums[1], nums[3]), Point(nums[2], nums[4]))
end
const input = load(file)

function part1(input::Area)
    n = -input.ll.y - 1
    n*(n + 1)÷2
end

assertequal(part1(input), 3160)

@assert input.ll.x > 0
function Base.iterate(muzzle_velocity::Point, state=Shot(muzzle_velocity))
    # Won't hit anything ever again.
    ((state.vel.y < 0 && state.loc.y < input.ll.y) ||
    (state.vel.x > 0 && state.loc.x > input.ur.x)) && return nothing

    pos = Point(state.loc.x + state.vel.x, state.loc.y + state.vel.y)
    vel = Point(max(0, state.vel.x - 1), state.vel.y - 1)
    pos, Shot(pos, vel)
end

Base.occursin(p::Point, a::Area) = a.ll.x <= p.x <= a.ur.x && a.ll.y <= p.y <= a.ur.y

part2() = count(Iterators.product(1:input.ur.x, -99:99)) do tup
    any(occursin(input), Point(tup...))
end

assertequal(part2(), 1928)
