using Test
using GeometricAlgebraModels.GeometricAlgebra

test() = cd(dirname(@__FILE__)) do
	include("conformal.jl")
	nothing
end

test()