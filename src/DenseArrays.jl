module DenseArrays

using Base: OneTo, @propagate_inbounds

using ArrayInterface
using ArrayInterface: ismutable, known_first, known_step
using StaticRanges: OneToSRange

export
    DArray,
    FixedMutable,
    FixedMutableVector,
    FixedImmutable,
    FixedImmutableVector,
    StaticMutableVector,
    StaticImmutableVector

include("collections.jl")
include("vectors.jl")
include("darray.jl")

as_immutable(x::FixedMutable{T}) where {T} = FixedImmutable{T}(x)
as_immutable(x::FixedImmutable{T}) where {T} = x

as_mutable(x::FixedImmutable{T}) where {T} = FixedMutable{T}(x)
as_mutable(x::FixedMutable{T}) where {T} = x

end # module
