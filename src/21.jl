using Underscores
using FunctionalCollections

const Str = SubString
const Storage = Set{Str}

struct Problem
    ingredients::Storage
    at_least::Storage
end

function parse_file(f)
    splitter = " (contains "

    re = Problem[]
    for line in eachline(f)
        @assert occursin(splitter, line)
        ing, allergens = split(line, splitter)
        push!(re, Problem(Set(split(ing)), Set(split(allergens[1:end-1], ", "))))
    end
    re
end

function load()
    open("$(@__DIR__)/../inputs/21.txt", "r") do f
        parse_file(f)
    end
end

function ex1(problem::Array{Problem})
    all_ing = Storage()
    all_all = Storage()
    for p in problem
        union!(all_ing, p.ingredients)
        union!(all_all, p.at_least)
    end

    unsafe = Storage()

    for allergen in all_all
        int = Storage()
        for p in problem
            allergen in p.at_least || continue
            combiner = isempty(int) ? union! : intersect!
            combiner(int, p.ingredients)
        end
        union!(unsafe, int)
    end

    safe = setdiff(all_ing, unsafe)

    sum(safe) do ing
        count(p -> ing in p.ingredients, problem)
    end
end

function ex2(problem::Array{Problem}, mapped::PersistentArrayMap{Str,Str}, allergens)::Union{Nothing,PersistentArrayMap{SubString,SubString}}
    length(mapped) == allergens && return mapped

    for p in problem
        for allergen in p.at_least
            allergen in keys(mapped) && continue
            # Now we have a candidate for mapping and find all possible ingredients.
            candidates = @_ filter(allergen::Str in _.at_least, problem) |> mapreduce(Set(_.ingredients), intersect, __)
            # But not the ones already mapped.
            setdiff!(candidates, values(mapped))

            for candidate in candidates
                sub = ex2(problem, assoc(mapped, allergen, candidate), allergens)
                !isnothing(sub) && return sub
            end
        end
    end
end

function ex2(problem::Array{Problem}, allergens=8)
    increasing_allergens = sort(problem, by=p -> length(p.at_least))
    mappings = ex2(increasing_allergens, PersistentArrayMap{Str,Str}(), allergens)
    @_ mappings |> keys |> collect |> sort |> map(mappings[_], __) |> join(__, ',')
end

problem = load()

println("Appearance count: ", ex1(problem))
println("Canonical dangerous ingredient list: ", ex2(problem))









using Test

@testset "Allergen Assessment" begin
    @testset "example 1" begin
        input1 = """
        mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
        trh fvjkl sbzzf mxmxvkd (contains dairy)
        sqjhc fvjkl (contains soy)
        sqjhc mxmxvkd sbzzf (contains fish)
        """

        example1 = parse_file(IOBuffer(input1))

        @test ex1(example1) == 5
        @test ex2(example1, 3) == "mxmxvkd,sqjhc,fvjkl"
    end

    @testset "results" begin
        @test ex1(problem) == 2556
        @test ex2(problem) == "vcckp,hjz,nhvprqb,jhtfzk,mgkhhc,qbgbmc,bzcrknb,zmh"
    end
end
