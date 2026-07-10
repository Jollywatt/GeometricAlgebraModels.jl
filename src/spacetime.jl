module Spacetime

using StyledStrings

using GeometricAlgebra
import GeometricAlgebra: Multivector, canonical_signature, signature_promote_rule, signature_convert

using ..GeometricAlgebraModels: showfields, StandardFormMultivector
import ..GeometricAlgebraModels: standardform, showformula

export Lorentzian
export SpacetimeBlade, SpacelikeBlade, LightlikeBlade, TimelikeBlade
export timevector, boost, refl, spacetimesplit


# metric signature

struct Lorentzian{Sig} end
canonical_signature(::Type{Lorentzian{Sig}}) where Sig = (canonical_signature(Sig)..., -1)

function GeometricAlgebra.get_basis_display_style(sig::Type{<:Lorentzian})
	n = dimension(sig)
	BasisDisplayStyle(n, indices=[1:n - 1; 0])
end

signature_promote_rule(::Val{Lorentzian{0}}, ::Val{Sig}) where Sig = Lorentzian{Sig}
signature_promote_rule(::Val{Lorentzian{0}}, ::Val{Lorentzian{Sig}}) where Sig = Lorentzian{Sig}

signature_promote_rule(::Val{Lorentzian{Sig}}, ::Val{Sig}) where Sig = Lorentzian{Sig}

signature_convert(::Val{Lorentzian{Sig}}, a::BasisBlade{Lorentzian{0},1}) where Sig = BasisBlade{Lorentzian{Sig}}(a.coeff, UInt(1) << dimension(Sig))
signature_convert(::Val{Lorentzian{Sig}}, a::Multivector{Lorentzian{0},1}) where Sig = Multivector{Lorentzian{Sig},1}(zeros(dimension(Sig))..., a.comps[end])
signature_convert(::Val{Lorentzian{Sig}}, a::AbstractMultivector{Sig}) where Sig = embed(Lorentzian{Sig}, a)

unembed(X::AbstractMultivector{Lorentzian{Sig}}) where Sig = embed(Val(Sig), X)


# basis vectors

timevector(sig=0) = basis(Lorentzian{sig}, 1, dimension(sig) + 1)


# versors

boost(ζ::Grade{1}) = exp(2\timevector()∧ζ)
boost(ζ::Grade{1}, X) = sandwich_prod(boost(ζ), X)




refl(A, u::Grade{1}) = grade(involution(A)*u*inv(A), 1)

spacetimesplit(a::Multivector{Lorentzian{Sig},1}) where Sig = (unembed(a), a.comps[end])

# standard blades

"""
	SpacetimeBlade{Sig,K} >:
		SpacelikeBlade{Sig,K}
		LightlikeBlade{Sig,K}
		TimelikeBlade{Sig,K}

A `K`-blade in a Lorenzian space `Lorentzian{Sig}`, expressed in terms only of a blade
`E` in the base space `Sig` and the timelike basis vector `v0`.

| Value | Mathematical form |
|:-----|:-----|
| `SpacelikeBlade(E)` | ``𝙱(β, E)`` |
| `LightlikeBlade(E, u)` | ``E ∧ (u + v₀)`` |
| `TimelikeBlade(E)` | ``𝙱(β, E ∧ v₀)`` |

Any blade in `Lorentzian{Sig}` is of one fo
"""
abstract type SpacetimeBlade{Sig,K} <: StandardFormMultivector{Sig,K} end
struct SpacelikeBlade{Sig,K} <: SpacetimeBlade{Sig,K}
	E::Multivector{Sig,K}
	ζ::Multivector{Sig,1}
end
struct LightlikeBlade{Sig,K,G} <: SpacetimeBlade{Sig,K}
	E::Multivector{Sig,G}
	n::Multivector{Sig,1}
	LightlikeBlade(E::Multivector{Sig,G}, n::Multivector{Sig,1}) where {Sig,G} = new{Sig,G + 1,G}(E, n)
end
struct TimelikeBlade{Sig,K,G} <: SpacetimeBlade{Sig,K}
	E::Multivector{Sig,G}
	ζ::Multivector{Sig,1}
	TimelikeBlade(E::Multivector{Sig,G}, ζ) where {Sig,G} = new{Sig,G + 1,G}(E, ζ)
end

function standardform(X::Multivector{Lorentzian{Sig}}) where Sig
	s = X⊙~X
	ε = √eps(float(eltype(X)))
	v0 = timevector()
	if abs(s) < ε
		# lightlike
		E = unembed(X⨽inv(v0))
		n = unembed(inv(E)⨼X)
		LightlikeBlade(E, n)
	elseif s > 0
		# spacelike
		µ = 2\(v0 + refl(X, v0))
		µspace, µtime = spacetimesplit(µ)
		ζ = atanh(µspace/µtime)
		E = unembed(boost(-ζ, X))
		SpacelikeBlade(E, ζ)
	else
		# timelike
		µ = 2\(v0 - refl(X, v0))
		µspace, µtime = spacetimesplit(µ)
		ζ = atanh(µspace/µtime)
		E = unembed(boost(-ζ, X)⨽inv(v0))
		TimelikeBlade(E, ζ)
	end
end

Multivector(X::SpacelikeBlade) = boost(X.ζ, X.E)
Multivector(X::LightlikeBlade) = X.E∧(X.n + timevector())
Multivector(X::TimelikeBlade) = boost(X.ζ, X.E∧timevector())


showformula(::Type{<:SpacelikeBlade}) = styled"boost({bold:ζ}, {bold:E})"
showformula(::Type{<:LightlikeBlade}) = styled"{bold:E} ∧ ({bold:n} + v0)"
showformula(::Type{<:TimelikeBlade}) = styled"boost({bold:ζ}, {bold:E} ∧ v0)"


end
