using Utils
using Test

@testset "@something_nothing" begin
    @testset "doesn't throw" begin
        @test isnothing(@something_nothing nothing)
        @test isnothing(@something_nothing nothing nothing)
        @test isnothing(@something_nothing nothing nothing nothing)
    end

    @testset "unwrapping" begin
        @test (@something_nothing Some(0)) == 0
        @test (@something_nothing nothing Some(0)) == 0
        @test (@something_nothing nothing nothing Some(0)) == 0
        @test (@something_nothing nothing nothing Some(0) nothing) == 0
        @test isnothing(@something_nothing Some(nothing) 1)
        @test isnothing(@something_nothing nothing Some(nothing) 1)
        @test isnothing(@something_nothing nothing Some(nothing) 1 nothing)
    end

    @testset "wrapped nothing at the end" begin
        @test isnothing(@something_nothing Some(nothing))
        @test isnothing(@something_nothing nothing Some(nothing))
        @test isnothing(@something_nothing nothing nothing Some(nothing))
    end

    @testset "escaping" begin
        val = 2

        @test_throws DomainError (@something_nothing sqrt(1 - val))
        @test (@something_nothing nothing (1 - val)) == -1
    end
end
