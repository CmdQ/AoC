module utils
export @something

function _something_impl(things)
    head, tail = Iterators.peel(things)
    if isempty(tail)
        :(something($(esc(head))))
    else
        quote
            local evalued = $(esc(head))
            if isnothing(evalued)
                $(_something_impl(tail))
            else
                something(evalued)
            end
        end
    end
end

macro something(things...)
    _something_impl(things)
end


end
