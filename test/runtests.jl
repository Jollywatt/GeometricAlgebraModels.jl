using Test
using GeometricAlgebraModels.GeometricAlgebra

test() = cd(dirname(@__FILE__)) do
	include("conformal.jl")
	include("spacetime.jl")
	include("mesh.jl")
	nothing
end

test()
