using Test
using GeometricAlgebraModels.GeometricAlgebra

test() = cd(dirname(@__FILE__)) do
	include("conformal.jl")
	include("lorentzian.jl")
	include("mesh.jl")
	nothing
end

test()