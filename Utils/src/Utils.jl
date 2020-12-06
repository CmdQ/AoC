module Utils
import Base
export @something
export @something_nothing

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
    split(s -> s == str, buffer)
end

function Base.split(buffer::Base.IO)
    split(isempty, buffer)
end

end
