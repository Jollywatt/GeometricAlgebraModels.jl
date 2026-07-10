module LieSphereGeometry

using GeometricAlgebra
import GeometricAlgebra: signature_convert, signature_promote_rule, canonical_signature, get_basis_display_style


using ..GeometricAlgebraModels.Conformal
using ..GeometricAlgebraModels.Spacetime

using GeometricAlgebraModels: opnsmesh


import .Conformal: opns, ipns

export timevector
export LSG, liesphere
export OrientedPlane, OrientedSphere

const LSG{Sig} = CGA{Lorentzian{Sig}}
# LorenzianSig + CGA = LSG
signature_promote_rule(::Val{Lorentzian{0}},   ::Val{CGA{0}}) = LSG{0}
signature_promote_rule(::Val{Lorentzian{0}},   ::Val{CGA{Sig}}) where Sig = LSG{Sig}
signature_promote_rule(::Val{Lorentzian{0}},   ::Val{LSG{Sig}}) where Sig = LSG{Sig}
signature_promote_rule(::Val{Lorentzian{Sig}}, ::Val{CGA{0}}) where Sig = LSG{Sig}
signature_promote_rule(::Val{Lorentzian{Sig}}, ::Val{CGA{Sig}}) where Sig = LSG{Sig}

signature_promote_rule(::Val{LSG{0}}, ::Val{Sig}) where Sig = LSG{Sig}
signature_promote_rule(::Val{LSG{0}}, ::Val{Lorentzian{0}}) = LSG{0}
signature_promote_rule(::Val{LSG{0}}, ::Val{Lorentzian{Sig}}) where Sig = LSG{Sig}
signature_promote_rule(::Val{LSG{0}}, ::Val{CGA{Sig}}) where Sig = LSG{Sig}
signature_promote_rule(::Val{LSG{0}}, ::Val{LSG{Sig}}) where Sig = LSG{Sig}
signature_promote_rule(::Val{LSG{Sig}}, ::Val{Sig}) where Sig = LSG{Sig}
signature_promote_rule(::Val{LSG{Sig}}, ::Val{Lorentzian{0}}) where Sig = LSG{Sig}
signature_promote_rule(::Val{LSG{Sig}}, ::Val{CGA{Sig}}) where Sig = LSG{Sig}


signature_convert(::Val{LSG{0}}, a::AbstractMultivector{Lorentzian{0}}) = embed(LSG{0}, a)
signature_convert(::Val{LSG{0}}, a::AbstractMultivector{CGA{0}}) = permutedims(embed(LSG{0}, a), [3, 1, 2])

signature_convert(::Val{LSG{Sig}}, a::AbstractMultivector{CGA{0}}) where Sig = signature_convert(Val(LSG{Sig}), signature_convert(Val(LSG{0}), a))
signature_convert(::Val{LSG{Sig}}, a::AbstractMultivector{LSG{0}}) where Sig = let n = dimension(Sig)
	permutedims(embed(LSG{Sig}, a), [4:n + 3; 1; 2; 3])
end
signature_convert(::Val{LSG{Sig}}, a::AbstractMultivector{Sig}) where Sig = embed(LSG{Sig}, a)

function signature_convert(::Val{LSG{Sig}}, a::AbstractMultivector{CGA{Sig}}) where Sig
	n = dimension(Sig)
	permutedims(embed(LSG{Sig}, a), [1:n; n + 3; n + 1; n + 2])
end

signature_convert(::Val{LSG{Sig}}, a::AbstractMultivector{Lorentzian{0}}) where Sig = signature_convert(Val(LSG{Sig}), signature_convert(Val(Lorentzian{Sig}), a))
signature_convert(::Val{LSG{Sig}}, a::AbstractMultivector{Lorentzian{Sig}}) where Sig = embed(LSG{Sig}, a)

abstract type LieSphere{Sig} end

struct OrientedPlane{Sig} <: LieSphere{Sig}
	n::Multivector{Sig,1}
	d::Float64
end

struct OrientedSphere{Sig} <: LieSphere{Sig}
	p::Multivector{Sig,1}
	r::Float64
end

struct PointAtInfinity{Sig} <: LieSphere{Sig} end

function liesphere(x::AbstractMultivector{LSG{Sig}}) where Sig
	@assert abs(x⊙x) < 1e-6
	o, oo = nullbasis()
	v0 = timevector()
	a = x⊙-oo
	if abs(a) < 1e-10
		# oriented plane
		n = Spacetime.unembed(Conformal.unembed(x))
		norm = √(n⊙n)
		n /= norm
		x /= norm
		d = x⊙-o
		OrientedPlane(n, d)
	else
		x /= a
		# oriented sphere
		p, r = Spacetime.spacetimesplit(Conformal.unembed(x))
		OrientedSphere(p, r)

	end
end


opns(A::AbstractMultivector{<:LSG}) = vec(liesphere.(opnsmesh(A)))
ipns(A::AbstractMultivector{<:LSG}) = vec(liesphere.(opnsmesh(hodgedual(A))))

end
