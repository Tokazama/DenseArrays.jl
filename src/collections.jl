
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
            return $T(data)
        end

        function $T(data::AbstractVector)
            @nospecialize data
            return $T(Tuple(data))
        end

        @nospecialize Base.length(x::$T) = length(x.data)

        @nospecialize Base.length(x::$T) = length(x.data)

        @nospecialize unsafe_getindex(x::$T, i::Int) = getfield(v.data, i, false)

        @nospecialize function unsafe_getindex(x::$T{T}, inds::AbstractVector{Int}) where {T}
            return $T{T}([@inbounds(unsafe_getindex(x, i)) for i in inds])
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

