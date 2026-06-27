

"""
	root_of_diagonal_quadratic_form(λ, [z])

Find a vector `z₀` near to the initial `z` which satisfies
```
z₀'D*z₀ == sum(@. λ*z₀^2) ≈ 0
```
where `D = Diagonal(λ)` is a diagonal matrix with main diagonal `λ::AbstractVector`.

If `z` is `nothing`, find a random root near `randn(length(λ))`.
"""
root_of_diagonal_quadratic_form(λ::AbstractVector, ::Nothing) = root_of_diagonal_quadratic_form(λ, randn(length(λ)))
function root_of_diagonal_quadratic_form(λ::AbstractVector, z::AbstractVector{T}) where T
	@assert length(λ) == length(z)
	if all(>(0), λ) || all(<(0), λ)
		return zero(z)
	end

	ε = eps(eltype(λ))
	pos = λ .> ε
	neg = λ .< -ε

	z[pos] /= sqrt(sum(abs2, z[pos]))
	z[neg] /= sqrt(sum(abs2, z[neg]))
	# z[@. !pos & !neg]

	if !any(pos) || !any(neg)
		# if there are no positive or no negative entries,
		# then all coeffs of nonzero entries must be zero
		# because they cannot be cancelled out by something of opposite sign
		z[@. pos || neg] *= 0
	end

	nonzero = pos .|| neg
	z[nonzero] ./= sqrt.(abs.(λ[nonzero]))

	return z
end



halfsphere(θ::NTuple{N}) where N = halfsphere(SVector{N,Float64}(θ))
halfsphere(θ::AbstractVector) = cumprod([1; sin.(θ)]).*[cos.(θ); 1]

"""
	solutionmesh(λ::AbstractVector{<:Real}, n)

Discretised manifold of solutions to the equation `z'Λ*z == 0` where `Λ = Diagonal(λ)`.

Returns an array of solutions where each axis corresponds to a degree of
freedom in the solution space, ignoring overall scaling of solutions.

Each axis corresponding to a continuous d.o.f. is samples with `n` values.
"""
function solutionmesh(λ::AbstractVector{<:Real}, n, rlims=(-10, 10); maxobjects=Inf)
	ε = √eps(float(eltype(λ)))
	pos = λ .> ε
	neg = λ .< -ε
	nul = @. !pos & !neg
	p, q, r = count.((pos, neg, nul))

	if p*q == 0 && r == 0
		# no solutions
		return SVector{length(λ),Float64}[]
	end

	if p*q > 0
		pm = (+1, -1)
		pdims, qdims = p - 1, q - 1
	else
		pm = (1,)
		pdims = qdims = 0
	end

	dims = r
	if p*q > 0
	  dims += pdims + qdims
	end
	dims += r

	n = floor(Int, min(n, maxobjects^(1/dims)))

	params = ()
	if p*q > 0
		params = (
			Iterators.product(fill(range(0, π, length=n)[1:end-1], pdims)...),
			Iterators.product(fill(range(0, π, length=n)[1:end-1], qdims)...),
			(+1,-1),
		)
	end
	if r > 0
		params = (params..., Iterators.product(fill(range(rlims..., length=n), r)...))
	end

	params = Iterators.product(params...)

	z = zeros(length(λ), size(params)...)::Array{Float64}
	iter = zip(CartesianIndices(size(params)), params)

	if p*q > 0
		σ = ones(size(λ))
		@. σ[pos | neg] /= √abs(λ[pos | neg])
		for (I, param) in iter
			θp, θq, pm = param
			z[pos,I] .= halfsphere(θp)
			z[neg,I] .= pm*halfsphere(θq)
			z[:,I] .*= σ
		end

		if ndims(params) > 1
			# by reversing one of the dimensions on the pm = -1 region
			# we ensure faces have consistent normals
			# (works when p == 2 at least)
			# colons = fill(:, ndims(params))
			# z[colons...,2] = reverse(z[colons...,2], dims=2)
		end
	end

	if r > 0
		for (I, p) in iter
			z[nul,I] .= p[end]
		end
	end

	collect(reshape(reinterpret(SVector{length(λ),eltype(z)}, z), size(params)))
end


function opnsmesh(X::AbstractMultivector, n=32; maxobjects=2^9)
	# first, find the diagonal quadratic form to solve
	A = stack(x.comps for x in factorblade(X))
	η = Diagonal(collect(canonical_signature(signature(X))))
	B = Symmetric(A'*η*A)
	λ, U = eigen(B, sortby=identity)

	z = solutionmesh(λ, n; maxobjects)

	xs = Ref(A*U).*z
	Multivector{signature(X),1}.(xs)
end

struct Mesh{N,T}
	vertices::Vector{NTuple{N,T}}
	edges::Vector{NTuple{2,Int}}
	faces::Vector{Union{NTuple{3,Int},NTuple{4,Int}}}
end

Base.show(io::IO, m::Mesh) = (summary(io, m); print(io, "(…)"))

function Base.show(io::IO, ::MIME"text/plain", m::Mesh)
  summary(io, m)
  println(io, " with:")
  println(io, " $(length(m.vertices)) vertices")
  println(io, " $(length(m.edges)) edges")
  println(io, " $(length(m.faces)) faces")
end

Mesh(verts::AbstractArray{<:Multivector{Sig,1}}; kwargs...) where Sig = Mesh([Tuple(v.comps) for v in verts]; kwargs...)

function Mesh(verts::AbstractArray{T,N};
		edgedims::Union{Nothing,Vector{Int}}=nothing,
		facedims::Union{Nothing,Vector{NTuple{2,Int}}}=nothing,
	) where {T,N}
	edges = NTuple{2,Int}[]
	faces = Union{NTuple{3,Int},NTuple{4,Int}}[]
	ids = reshape(eachindex(verts), size(verts))
	kids = CartesianIndices(ids)
	ci(i) = CartesianIndex(ntuple(==(i), N))

	if isnothing(edgedims)
		edgedims = findall(>(2), size(verts))
	end
	if isnothing(facedims)
		facedims = length(edgedims) == 2 ? [Tuple(edgedims)] : NTuple{2,Int}[]
	end


	Δs = ci.(edgedims)
	Γs = [(ci(j), ci(k)) for (j, k) in facedims]
	for I in CartesianIndices(verts)
		for Δ in Δs
			I + Δ in kids || continue
			push!(edges, (ids[I], ids[I + Δ]))
		end
		for (Γi, Γj) in Γs
			I + Γi + Γj in kids || continue
			(Γi, Γj) = (Γj, Γi)
			push!(faces, (ids[I], ids[I + Γi], ids[I + Γi + Γj], ids[I + Γj]))
		end
	end
	Mesh(vec(verts), edges, faces)
end
