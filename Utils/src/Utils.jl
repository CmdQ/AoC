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

function split_blocks(str::Base.String, buffer::Base.IO)
    @_ split_blocks(_ == str, buffer)
end

function split_blocks(buffer::Base.IO)
    split_blocks(isempty, buffer)
end

slurp(filename::AbstractString) = read(filename, String)

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

end
