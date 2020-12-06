using Utils
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
        @test (@something nothing nothing Some(0)) == 0
        @test (@something nothing nothing Some(0) nothing) == 0
        @test isnothing(@something Some(nothing) 1)
        @test isnothing(@something nothing Some(nothing) 1)
        @test isnothing(@something nothing Some(nothing) 1 nothing)
    end

    @testset "wrapped nothing at the end" begin
        @test isnothing(@something Some(nothing))
        @test isnothing(@something nothing Some(nothing))
        @test isnothing(@something nothing nothing Some(nothing))
    end

    @testset "escaping" begin
        val = 2

        @test_throws DomainError (@something sqrt(1 - val))
        @test (@something nothing (1 - val)) == -1
    end
end

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

@testset "split" begin
    @testset "test default empty line" begin
        @test split(IOBuffer("")) == [""]
        @test split(IOBuffer("\n")) == ["", ""]
        @test split(IOBuffer("hello\nworld\n\nyou're big\n")) == ["hello\nworld", "you're big"]
        @test split(IOBuffer("hello\nworld\n\nyou're big")) == ["hello\nworld", "you're big"]
        @test split(IOBuffer("hello\nworld\n\n\nyou're big")) == ["hello\nworld", "", "you're big"]
    end

    @testset "test given separator" begin
        @test split("###", IOBuffer("")) == [""]
        @test split("###", IOBuffer("###")) == ["", ""]
        @test split("###", IOBuffer("hello\nworld\n###\nyou're big\n")) == ["hello\nworld", "you're big"]
        @test split("###", IOBuffer("hello\nworld\n###\nyou're big")) == ["hello\nworld", "you're big"]
        @test split("###", IOBuffer("hello\nworld\n###\n###\nyou're big")) == ["hello\nworld", "", "you're big"]
    end
end