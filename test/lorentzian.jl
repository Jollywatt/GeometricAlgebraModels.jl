using GeometricAlgebraModels.LorentzianAlgebra

@testset "lorentzian standard forms" begin
	v0 = timevector()

	@testset for n in 0:4, k in 1:n
		E = wedge(randn(), randn(Multivector{n,1},k)...)
		ξ = randn(Multivector{n,1})
		u = ξ/√(ξ⊙ξ)
		@test u⊙u ≈ 1

		spacelike = boost(ξ, E)
		lightlike = E∧(u + v0)
		timelike = boost(ξ, E∧v0)

		@test Multivector(standardform(spacelike)) ≈ spacelike
		@test Multivector(standardform(lightlike)) ≈ lightlike
		@test Multivector(standardform(timelike)) ≈ timelike


	end
end