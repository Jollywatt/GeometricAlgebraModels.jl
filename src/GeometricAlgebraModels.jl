module GeometricAlgebraModels

using GeometricAlgebra
using LinearAlgebra
using StaticArrays

export standardform
export translate

export Projective
export Conformal
export LorentzianAlgebra

include("common.jl")
include("conformal.jl")


end # module GeometricAlgebraModels
