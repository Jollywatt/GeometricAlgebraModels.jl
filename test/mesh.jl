using GeometricAlgebraModels: solutionmesh

@testset "solution meshes" begin
	@testset for λ in [
		[1],
		[1,1],
		[1,-1],
		[1,-1,1],
		[-1,1,-1],
		[0],
		[0,0],
		[0,1,0,-1],
		[0,1,0,-1,1],

		[1,-2],
		[1,1,-2],
		[10,-5,0.5],
	]
		Z = solutionmesh(λ, 20)
		@test length(unique(Z)) == length(Z)
		@test all(isapprox(sum(λ.*z.^2), 0, atol=1e-10) for z in Z)
	end
end