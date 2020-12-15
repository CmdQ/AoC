input = [1,12,0,20,8,16]

struct Seen
    before::Int
    earlier::Int
end
Seen(index) = Seen(index, 0)

function remember(last, what, round)
    if !haskey(last, what)
        last[what] = Seen(round)
    else
        last[what] = Seen(round, last[what].before)
    end
end

function ex(last::Dict{Int,Seen}, which, round, current)
    while round <= which
        p = last[current]
        if p.earlier == 0 && p.before == round - 1
            current = 0
        else
            @assert p.earlier != 0
            current = p.before - p.earlier
        end
        remember(last, current, round)
        round += 1
    end
    current
end

function ex(nums, which)
    which <= length(nums) && return nums[which]

    d = Dict{Int,Seen}()
    for (idx, elm) in enumerate(nums)
        remember(d, elm, idx)
    end

    ex(d, which, length(nums) + 1, nums[end])
end


const YEAR = 2020
const HUGE = 30_000_000
println("The $(YEAR)th number spoken is: ", ex(input, YEAR))
println("The $(HUGE) number is: ", ex(input, HUGE))









using Test

@testset "Rambunctious Recitation" begin
    @testset "example 1" begin
        @test ex([1,3,2], YEAR) == 1
        @test ex([2,1,3], YEAR) == 10
        @test ex([1,2,3], YEAR) == 27
        @test ex([2,3,1], YEAR) == 78
        @test ex([3,2,1], YEAR) == 438
        @test ex([3,1,2], YEAR) == 1836
    end

    #@testset "example 2" begin
    #    @test ex([0,3,6], HUGE) == 175594
    #    @test ex([1,3,2], HUGE) == 2578
    #    @test ex([2,1,3], HUGE) == 3544142
    #    @test ex([1,2,3], HUGE) == 261214
    #    @test ex([2,3,1], HUGE) == 6895259
    #    @test ex([3,2,1], HUGE) == 18
    #    @test ex([3,1,2], HUGE) == 362
    #end

    @testset "results" begin
        @test ex(input, YEAR) == 273
        @test ex(input, HUGE) == 47205
    end
end
