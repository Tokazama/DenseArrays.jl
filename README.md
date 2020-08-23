# DenseArrays.jl

Experimental package with the goal of producing a central type of vectors that are:
| Type | Description|
|------|------------|
| `FixedImmutableVector` | immutable with fixed length |
| `StaticImmutableVector` | immutable with length known at compile time (static) |
| `FixedMutableVector` | mutable with fixed length |
| `StaticMutableVector` | mutable with length known at compile time (static) |

The only multidimensional array type is `DArray`, which is a dense array that wraps any one of these vectors (or `Base.Vector`).
An N dimensional `DArray` has N axes to providing shape.
The product of the lengths of all axes is equal to the length of the underlying data vector.



```julia
julia> using DenseArrays

julia> function element_index_test(x)
           for i in rand(1:length(x), length(x))
               x[i]
           end
       end

julia> dynamic_vector = rand(200);

julia> fixed_immutable_vector = FixedImmutableVector(dynamic_vector);

julia> @time element_index_test(dynamic_vector)
  0.021871 seconds (43.95 k allocations: 2.228 MiB)

julia> @time element_index_test(dynamic_vector)
  0.000005 seconds (1 allocation: 1.766 KiB)

julia> @time element_index_test(fixed_immutable_vector)
  0.011446 seconds (14.78 k allocations: 781.453 KiB)

julia> @time element_index_test(fixed_immutable_vector)
  0.000006 seconds (1 allocation: 1.766 KiB)

```

Some constructors...
```julia
julia> FixedImmutableVector(1, 2, 3);

julia> FixedImmutableVector([1, 2, 3]);
```
