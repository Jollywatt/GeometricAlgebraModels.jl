using GeometricAlgebraModels.Conformal

@testset "conformal standard forms" begin

	@testset for dim in 0:4
		n0, noo = nullbasis(dim)

		@testset for k in 0:dim
			for _ in 1:10
				E = k > 0 ? wedge(randn(Multivector{dim,1}, k)...) : Multivector{dim,0}(randn())
				p = randn(Multivector{dim,1})
				r² = randn()

				dir = E∧noo
				flat = translate(p, n0∧E∧noo)
				dualflat = translate(p, CGA(E))
				round = translate(p, (n0 + 2\r²*noo)∧E)

				dirblade = standardform(dir)
				flatblade = standardform(flat)
				dualflatblade = standardform(dualflat)
				roundblade = standardform(round)

				@test dirblade isa Conformal.DirectionBlade
				@test flatblade isa Conformal.FlatBlade
				@test dualflatblade isa Conformal.DualFlatBlade
				@test roundblade isa Conformal.RoundBlade

				@test Multivector(dirblade) ≈ dir
				@test Multivector(flatblade) ≈ flat
				@test Multivector(dualflatblade) ≈ dualflat
				@test Multivector(roundblade) ≈ round
			end
		end
	end
end


@testset "conformal standard forms with null spans" begin

	@testset for dim in 0:4
		n0, noo = Conformal.nullbasis(dim)
		v0 = LorentzianAlgebra.timevector(dim)

		@testset for k in 1:dim - 1
			for _ in 1:10
				E = wedge(randn(Multivector{dim,1}, k)...)
				n̂ = randn(Multivector{dim,1})
				n̂ /= √(n̂⊙n̂)
				E = (E∧n̂)⋅n̂
				E = E∧(n̂ + v0)
				@test E^2 ≈ 0 atol=1e-10

				p = randn(Multivector{Lorentzian{dim},1})
				r² = randn()

				dir = E∧noo
				flat = translate(p, n0∧E∧noo)
				dualflat = translate(p, CGA(E))
				round = translate(p, (n0 + 2\r²*noo)∧E)

				dirblade = standardform(dir)
				flatblade = standardform(flat)
				dualflatblade = standardform(dualflat)
				roundblade = standardform(round)

				@test dirblade isa Conformal.DirectionBlade
				@test flatblade isa Conformal.FlatBlade
				@test dualflatblade isa Conformal.DualFlatBlade
				@test roundblade isa Conformal.RoundBlade

				@test Multivector(dirblade) ≈ dir
				@test Multivector(dualflatblade) ≈ dualflat
				@test_broken Multivector(flatblade) ≈ flat
				@test_broken Multivector(roundblade) ≈ round
			end
		end
	end
end
