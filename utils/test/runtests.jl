using utils
using Test

@testset "@something" begin
    @testset "throws" begin
        @test_throws ArgumentError @something nothing
        @test_throws ArgumentError @something nothing nothing
        @test_throws ArgumentError @something nothing nothing nothing
    end

    @testset "unwrapping" begin
        @test (@something Some(0)) == 0
        @test (@something nothing Some(0)) == 0
        @test (@something Some(nothing) 1) === nothing
        @test (@something nothing nothing Some(0)) == 0
        @test (@something nothing Some(nothing) 1) === nothing
        @test (@something nothing nothing Some(0) nothing) == 0
        @test (@something nothing Some(nothing) 1 nothing) === nothing
    end

    @testset "escaping" begin
        val = 2

        @test_throws DomainError (@something sqrt(1 - val))
        @test (@something nothing (1 - val)) == -1
    end
end
