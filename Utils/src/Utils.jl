module Utils
using OffsetArrays

export @something
export @something_nothing
export @aoc_str
export split_blocks
export slurp
export per_split
export per_line
export per_split_parse
export per_line_parse
export find_input
export zerobased
export curry
export curry2nd
export currylast
export assertequal
export boundaryconditions

using Chain
using Underscores

function _something_impl(thing)
    :(something($(esc(thing))))
end

function _something_impl(thing, rest...)
    quote
        local evalued = $(esc(thing))
        if isnothing(evalued)
            $(_something_impl(rest...))
        else
            something(evalued)
        end
    end
end

macro something(things...)
    _something_impl(things...)
end

function _something_nothing_impl(thing)
    quote
        local evaluated = $(esc(thing))
        if isa(evaluated, Some)
            evaluated.value
        else
            evaluated
        end
    end
end

function _something_nothing_impl(thing, rest...)
    quote
        local evalued = $(esc(thing))
        if isnothing(evalued)
            $(_something_nothing_impl(rest...))
        else
            something(evalued)
        end
    end
end

macro something_nothing(things...)
    _something_nothing_impl(things...)
end

function find_input(julia_file, lookfor=nothing)
    if isnothing(lookfor)
        num = escape_string(match(r"(\d+)\.jl$", julia_file)[1])
        lookfor = Regex("\\Q$num\\E[^\\/]*\\.txt\$")
    end
    dir, _, files = @chain julia_file begin
        dirname
        walkdir
        first
    end
    @chain files begin
        filter(fname -> occursin(lookfor, fname), _)
        Iterators.only
        joinpath(dir, _)
    end
end

slurp(filename::AbstractString) = read(filename, String)

function split_blocks(f, buffer::Base.IO)
    re = String[]
    block = String[]
    for line in eachline(buffer)
        if f(line)
            push!(re, join(block, '\n'))
            block = String[]
        else
            push!(block, line)
        end
    end
    push!(re, join(block, '\n'))
    re
end

split_blocks(str::Base.String, buffer::Base.IO) = @_ split_blocks(==(str), buffer)

split_blocks(buffer::Base.IO) = split_blocks(isempty, buffer)

per_split(str::AbstractString, sep=isspace, keepempty=true) = @_ str |> split(__, sep, keepempty=keepempty)

per_split(f::Function, str::AbstractString, sep=isspace, keepempty=true) = @_ str |> split(__, sep, keepempty=keepempty) |> map(f, __)

const NEWLINE = r"\r?\n"

per_line(str::AbstractString, keepempty=true) = per_split(str, NEWLINE, keepempty)

per_line(f::Function, str::AbstractString, keepempty=true) = per_split(f, str, NEWLINE, keepempty)

function per_split_parse(str::AbstractString, sep, ::Type{T} = Int) where {T <: Number}
    per_split(str, sep, false) do line
        parse(T, line)
    end
end

function per_line_parse(str::AbstractString, ::Type{T} = Int) where {T <: Number}
    per_line(str, false) do line
        parse(T, line)
    end
end

zerobased(array::AbstractArray{T,1}) where {T} = OffsetArray(array, OffsetArrays.Origin(0))
zerobased(array::AbstractArray{T,2}) where {T} = OffsetArray(array, OffsetArrays.Origin(0, 0))
zerobased(array::AbstractArray{T,3}) where {T} = OffsetArray(array, OffsetArrays.Origin(0, 0, 0))

curry(f::Function, x)::Function = Base.Fix1(f, x)
curry2nd(f::Function, x)::Function = Base.Fix2(f, x)
currylast(f::Function, x)::Function = (xs...) -> f(xs..., x)

function assertequal(result, compareto=nothing, _ = Union{})
    if !isnothing(compareto)
        if result == compareto
            println("Correct   result: $(result)")
        else
            println("INCORRECT result: $(result) should be $(compareto)")
        end
    else
        println("Unchecked result: $(result)")
    end
end

function assertequal(result::AbstractString)
    assertequal("\"$(escape_string(result))\"", nothing)
end

function assertequal(result::AbstractString, compareto::AbstractString)
    assertequal("\"$(escape_string(result))\"", "\"$(escape_string(compareto))\"", Union{})
end

function boundaryconditions(vector::AbstractArray{T,1}, fillvalue::Union{Nothing,T}=nothing) where T
    if fillvalue === nothing
        [vector[begin]; vector; vector[end]]
    else
        [fillvalue; vector; fillvalue]
    end
end

function boundaryconditions(matrix::AbstractArray{T,2}, fillvalue::Union{Nothing,T}=nothing) where T
    sub = mapslices(curry2nd(boundaryconditions, fillvalue), matrix, dims=2)
    if fillvalue === nothing
        head = permutedims(sub[firstindex(sub, 1),:])
        tail = permutedims(sub[lastindex(sub, 1),:])
        cat(head, sub, tail; dims=1)
    else
        filler = permutedims(fill(fillvalue, size(sub, 2)))
        cat(filler, sub, filler; dims=1)
    end
end

boundaryconditions(matrix, fillvalue::T) where T = boundaryconditions(matrix, convert(T, fillvalue))

end
