# DenseArrays.jl

Experimental package with the goal of producing a central type of vectors that are:
* immutable with fixed length
* immutable with length known at compile time (static)
* mutable with fixed length
* mutable with length known at compile time (static)

The only multidimensional array type is `DArray`, which is a dense array that wraps any one of these vectors (or `Base.Vector`).
An N dimensional `DArray` has N axes to providing shape.
The product of the lengths of all axes is equal to the length of the underlying data vector.
