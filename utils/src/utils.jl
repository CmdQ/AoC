module utils
export @something

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

end
