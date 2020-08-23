
function check_params(data, axs)
    if length(data) != prod(map(length, axs))
        error("The provided data has a length of $(length(data)) and the product of the axes sizes is $(prod(map(length, axs)))")
    else
        for i in axs
            known_first(i) === 1 || error("All indices must start at one: got $i")
        end
    end
end

_to_indices(i::Int) = OneTo{Int}(i)
_to_indices(i::AbstractUnitRange{Int}) = i

struct DArray{T,N,Axs<:NTuple{N,<:AbstractUnitRange{Int}},D<:Union{<:Vector{T},<:DVector{T}}} <: AbstractArray{T,N}
    data::D
    axes::Axs

    function DArray{T,N,Axs,D}(data::D, axs::Axs) where {T,N,Axs,D}
        check_params(data, axs)
        return new{T,N,Axs,D}(data, axs)
    end

    function DArray{T,N,Axs}(data, axs::Axs) where {T,N,Axs}
        return DArray{T,N,Axs,typeof(data)}(data, axs)
    end

    function DArray{T,N}(data, axs::NTuple{N,<:AbstractUnitRange{Int}}) where {T,N}
        return DArray{T,N,typeof(axs)}(data, axs)
    end

    function DArray{T,N}(data, axs::NTuple{N,<:Any}) where {T,N}
        return DArray{T,N}(data, _to_indices.(axs))
    end

    DArray{T}(data, axs::NTuple{N,<:Any}) where {T,N} = DArray{T,N}(data, axs)
end

Base.dataids(x::DArray) = Base.dataids(x.data)

Base.eachindex(x::DArray) = x.data.axis

Base.axes(A::DArray) = x.axes

Base.axes(A::DArray, i::Int) = getfield(x.axes, i)

Base.IndexStyle(::Type{<:DArray}) = IndexLinear()

# Linear Indexing
@propagate_inbounds Base.getindex(A::DArray, i::Int) = getindex(A.data, i)

@propagate_inbounds function Base.getindex(A::DArray, i::AbstractVector{<:Integer})
    return getindex(A.data, i)
end

#=
function unsafe_getindex(A::DArray, inds::Tuple{Vararg{<:Integer}})
    return unsafe_getindex(get_data(A), @inbounds(getindex(lininds(A), inds...)))
end

@propagate_inbounds function Base.getindex(A::DArray, i::Integer)
    @boundscheck if i < 1 || i > length(A)
        throw(BoundsError(A, i))
    end
    return unsafe_getindex(A, convert(Int, i))
end

@propagate_inbounds function Base.getindex(A::DArray, inds::AbstractVector{Integer})
    @boundscheck checkbounds(A, inds)
    return DArray(unsafe_getindex(A, inds))
end

@propagate_inbounds function Base.getindex(A::DArray, gr::GapRange{Integer})
    @boundscheck checkbounds(A, inds)
    return DArray(vcat(unsafe_getindex(x, first_range(gr)), unsafe_getindex(x, last_range(gr))))
end

unsafe_getindex(A::DArray, i::Int) = unsafe_getindex(get_data(A), i)
=#

