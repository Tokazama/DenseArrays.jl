
abstract type DVector{T,D} <: AbstractVector{T} end

for I in (:Immutable,:Mutable)
    VType = Symbol(:Fixed, I, :Vector)
    CollectionType = Symbol(:Fixed, I)

    str = """
        $VType

    Vector whose elements are $(lowercase(string(I))) and length is fixed.
    """
    @eval begin
        @doc $str
        struct $VType{T} <: DVector{T,$CollectionType{T}}
            data::$CollectionType{T}
            axis::OneTo{Int}

            function $VType{T}(data::$CollectionType{T}) where {T}
                @nospecialize data
                return new{T}(data, OneTo{Int}(length(data)))
            end

            function $VType{T}(data) where {T}
                @nospecialize data
                return $VType{T}($CollectionType(data))
            end

            function $VType(data) where {T}
                @nospecialize data
                return $VType{T}(data)
            end

            function $VType(data::$CollectionType{T}) where {T}
                @nospecialize data
                return $VType{T}(data)
            end
        end
    end
end

for I in (:Immutable,:Mutable)
    VType = Symbol(:Static, I, :Vector)
    CollectionType = Symbol(:Fixed, I)
    str = """
        $VType

        Vector whose elements are $(lowercase(string(I))) and length is known at compile time.
    """
    @eval begin
        @doc $str
        struct $VType{T,L} <: DVector{T,$CollectionType{T}}
            data::$CollectionType{T}
            axis::OneToSRange{Int,L}

            function $VType{T,L}(
                data::$CollectionType{T},
                axis::OneToSRange{Int,L},
                check_length::Bool=true
            ) where {T,L}
                check_length && length(data) === L || error("axis and data have different lengths.")
                return new{T,L}(data, axis)
            end

            function $VType{T}(data::$CollectionType{T}) where {T}
                L = length(data)
                @nospecialize data
                return $VType{T,L}(data, OneToSRange{Int}(L))
            end

            function $VType{T}(data) where {T}
                L = length(data)
                @nospecialize data
                return new{T,L}($CollectionType(data), OneToSRange{Int,L}())
            end

            function $VType(data) where {T}
                L = length(data)
                @nospecialize data
                return new{T,L}($CollectionType(data), OneToSRange{Int,L}())
            end

            function $VType(data::$CollectionType{T}) where {T}
                @nospecialize data
                return $VType{T}(data)
            end
        end
    end
end

ArrayInterface.ismutable(::Type{<:DVector{T,D}}) where {T,D} = ismutable(D)

Base.axes(v::DVector) = (v.axis,)

Base.length(v::DVector) = length(v.axis)

@propagate_inbounds function Base.getindex(v::DVector, i::Int)
    @boundscheck if i < 1 || i > length(v)
        throw(BoundsError(v, i))
    end
    return unsafe_getindex(v.data, i)
end

@propagate_inbounds function Base.setindex!(v::DVector, val, i::Int)
    @boundscheck if i < 1 || i > length(v)
        throw(BoundsError(v, i))
    end
    return unsafe_setindex!(v.data, val, i)
end

@propagate_inbounds function Base.getindex(
    v::Union{<:StaticMutableVector,<:FixedMutableVector},
    inds::AbstractVector{Int}
)

    @boundscheck boundscheck(v, inds)
    if known_length(inds) === nothing
        return FixedMutableVector{T}(unsafe_getindex(v.data, inds), OneTo{Int}(length(inds)))
    else
        return StaticMutableVector{T}(unsafe_getindex(v.data, inds), OneToSRange{Int}(known_length(inds)))
    end
end

@propagate_inbounds function Base.getindex(
    v::Union{<:StaticImmutableVector,<:FixedImmutableVector},
    inds::AbstractVector{Int}
)

    @boundscheck boundscheck(v, inds)
    if known_length(inds) === nothing
        return FixedImmutableVector{T}(unsafe_getindex(v.data, inds), OneTo{Int}(length(inds)))
    else
        return StaticImmutableVector{T}(unsafe_getindex(v.data, inds), OneToSRange{Int}(known_length(inds)))
    end
end

Base.dataids(x::StaticMutableVector) = (UInt(pointer(x.data)),)

Base.dataids(x::FixedMutableVector) = (UInt(pointer(x.data)),)

