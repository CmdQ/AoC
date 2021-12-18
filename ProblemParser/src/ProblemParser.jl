module ProblemParser

export Blocks
export Convert
export FirstRest
export LineMappings
export Lines
export Mappings
export Noop
export Rectangular
export Split

const universal_newlines = r"\r?\n|\v|\f|\u1c|\u1d|\u1e|\u85|\u2028|\u2029"
const doubled_newlines = Regex("(?:" * universal_newlines.pattern * "){2}")

abstract type GrammarElement end

Base.@kwdef struct Noop
    inspect::Bool = false
end

struct Split <: GrammarElement
    splitter
    per_element::Union{GrammarElement,Nothing}
    keepempty::Bool
    limit::Int
end
Split(splitter=isspace; keepempty=false, limit=0) = Split(splitter, nothing, keepempty, limit)
Split(per_element::GrammarElement; keepempty=false, limit=0) = Split(isspace, per_element, keepempty, limit)
Split(splitter, per_element::GrammarElement; keepempty=false, limit=0) = Split(splitter, per_element, keepempty, limit)

Lines(per_line::Union{GrammarElement,Nothing}=nothing; keepempty=false) = Split(universal_newlines, per_line, keepempty, 0)

Base.@kwdef struct Convert <: GrammarElement
    target_type::Type = Int
end

Base.@kwdef struct Rectangular <: GrammarElement
    per_entry::Union{GrammarElement,Nothing} = nothing
end

Blocks(per_block=nothing; keepempty=false) = Split(doubled_newlines, per_block, keepempty, 0)

struct FirstRest <: GrammarElement
    splitter
    for_first::Union{GrammarElement,Nothing}
    per_rest::Union{GrammarElement,Nothing}
end
FirstRest() = FirstRest(Lines(), nothing, nothing)
FirstRest(split_on, per_rest=nothing) = FirstRest(split_on, nothing, per_rest)

struct _Mappings
    splitter::Union{GrammarElement,Nothing}
    first_rest::FirstRest
end
Mappings(splitter, args...) = _Mappings(splitter, FirstRest(args...))
LineMappings(args...) = _Mappings(Lines(), FirstRest(args...))

Base.parse(::Nothing, anything) = anything

function Base.parse(noop::Noop, anything)
    noop.inspect && println(anything)
    anything
end

Base.parse(operation::GrammarElement, list::AbstractArray) = map(Base.Fix1(Base.parse, operation), list)

Base.parse(convert::Convert, text::Union{AbstractString, Char}) = parse(convert.target_type, text)

function Base.parse(split::Split, text::AbstractString)
    parts = Base.split(text, split.splitter; keepempty=split.keepempty, limit=split.limit)
    parse(split.per_element, parts)
end

function Base.parse(rectangular::Rectangular, text::AbstractString)
    if rectangular.per_entry isa Split
        splitfirst = parse(rectangular.per_entry, text)
        permutedims(reduce(hcat, splitfirst))
    else
        rows = parse(Lines(), text)
        chars_as_columns = map(collect, rows)
        transposed = reduce(hcat, chars_as_columns)
        parse(rectangular.per_entry, permutedims(transposed))
    end
end

function Base.parse(firstrest::FirstRest, text::AbstractString)
    first, rest = split(text, firstrest.splitter.splitter; keepempty=true, limit=2)
    parse(firstrest.for_first, first), parse(firstrest.per_rest, rest)
end

function Base.parse(mappings::_Mappings, text::AbstractString)
    kv_pairs = parse(mappings.splitter, text)
    parse(mappings.first_rest, kv_pairs) |> Dict
end

end # module
