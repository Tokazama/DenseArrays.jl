
function unsafe_getindex end

"""
    FixedImmutable

Ordered collection that has a fixed size and is immutable.
"""
struct FixedImmutable{T}
    data::Tuple{Vararg{T}}

    function FixedImmutable{T}(data::Tuple{Vararg{T}}) where {T}
        @nospecialize data
        return new{T}(data)
    end
end

"""
    FixedMutable

Ordered collection that has a fixed size and is mutable.
"""
mutable struct FixedMutable{T}
    data::Tuple{Vararg{T}}

    function FixedMutable{T}(data::Tuple{Vararg{T}}) where {T}
        @nospecialize data
        return new{T}(data)
    end
end

for T in (:FixedImmutable, :FixedMutable)
    @eval begin

        function $T(data::Tuple{Vararg{T}}) where {T}
            @nospecialize data
            return $T{T}(data)
        end

        function $T(data...)
            @nospecialize data
            return DenseArrays.$T(data)
        end

        function $T(data::AbstractVector)
            @nospecialize data
            return DenseArrays.$T(Tuple(data))
        end

        function unsafe_getindex(x::$T, i::Int)
            @nospecialize
            return getfield(x.data, i, false)
        end

        function Base.length(x::$T)
            @nospecialize
            return length(x.data)
        end
    end
end

ArrayInterface.ismutable(::Type{<:FixedImmutable}) = false

ArrayInterface.ismutable(::Type{<:FixedMutable}) = true

@propagate_inbounds function unsafe_setindex!(x::FixedMutable{T}, val, i::Int) where {T}
    if isbitstype(T)
        GC.@preserve x unsafe_store!(Base.unsafe_convert(Ptr{T}, pointer_from_objref(x)), convert(T, val), i)
    else
        error("setindex! with non-isbitstype eltype is not supported.")
    end
    return val
end

