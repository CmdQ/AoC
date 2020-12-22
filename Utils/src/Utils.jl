module Utils

export @something
export @something_nothing
export @aoc_str
export memoize

using Underscores

macro aoc_str(s)
    "$(@__DIR__)/../../inputs/" * s * (endswith(s, ".txt") ? "" : ".txt")
end

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

function Base.split(f, buffer::Base.IO)
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

function Base.split(str::Base.String, buffer::Base.IO)
    @_ split(_ == str, buffer)
end

function Base.split(buffer::Base.IO)
    split(isempty, buffer)
end

function memoize(f::Function)::Function
    cache = Dict()
    function(args...)
        if haskey(cache, args)
            cache[args]
        else
            re = f(args...)
            cache[args] = re
            re
        end
    end
end

end
