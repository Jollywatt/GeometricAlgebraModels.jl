using GeometricAlgebraModels.Conformal

#= encoding CGAGeometry subtypes =#

const Point = RoundGeometry{3,0}
const PointPair = RoundGeometry{3,1}
const Circle = RoundGeometry{3,2}
const Sphere = RoundGeometry{3,3}

const PointFlat = FlatGeometry{3,0}
const Line = FlatGeometry{3,1}
const Plane = FlatGeometry{3,2}

"""
	TangentBlade{Sig,K}

Tangent blades are a special case of round blades with zero radius.

| Value | Mathematical form |
|:-----|:-----|
| `TangentBlade(E)` | ``𝚃ₚ[n₀ ∧ E]`` |
| `RoundBlade(E, p, r2)` | ``𝚃ₚ[(n₀ + r2/2 n_∞) ∧ E]`` |

"""
struct TangentBlade{Sig,K} <: CGABlade{Sig,K}
	E::Multivector{Sig,K}
	p::Multivector{Sig,1}
end

const TangentPoint = TangentBlade{3,0}
const TangentVector = TangentBlade{3,1}
const TangentPlane = TangentBlade{3,2}

encode(X::Multivector{<:CGA}) = encode(standardform(X))
encode(geom::Union{EmptySet,PointAtInfinity}) = Rig("Empty")

function encode(X::RoundBlade)
	if abs(X.r2) < 1e-5
		encode(TangentBlade(X.E, X.p))
	else
		encode(X.r2 > 0 ? opns(X) : ipns(X))
	end
end

encode(X::FlatBlade) = encode(opns(X))
encode(X::DualFlatBlade) = encode(ipns(X))

function encode(X::Union{Point,Sphere})
	if abs(X.r2) < 1e-3
		Rig("Point", location=X.p)
	else
		Rig("Sphere",
			location=X.p,
			"Radius"=>√abs(X.r2),
			"Holes"=>X.r2 < 0,
		)
	end
end

function encode(X::Union{PointFlat,TangentPoint})
	Rig("Point", location=X.p)
end

encode(X::TangentVector) = Rig("Arrow Vector",
	location=X.p,
	"Vector"=>X.E,
)

encode(X::TangentPlane) = Rig("Spear Disk",
	location=X.p,
	"Normal"=>rdual(X.E),
	"Radius"=>√abs(X.E⊙X.E),
)

function encode(X::PointPair)
	if abs(X.r2) > 1e-3
		Rig("Point Pair",
			location=X.p,
			"Direction"=>X.E,
			"Radius"=>√abs(X.r2),
			"Show bar"=>true,
			"Thickness"=>0.01,
			"Dashed"=>X.r2 < 0,
		)
	else
		Rig("Arrow Vector",
			location=X.p,
			"Vector"=>X.E,
		)
	end
end

function encode(X::Circle)
	if abs(X.r2) > 1e-3
		Rig("Circle",
			location=X.p,
			"Radius"=>√abs(X.r2),
			"Normal"=>rdual(X.E),
			"Dashed"=>X.r2 < 0,
			"Dash ratio"=>0.5,
		)
	else
		Rig("Spear Disk",
			location=X.p,
			"Radius"=>√abs(X.E⊙X.E),
			"Normal"=>rdual(X.E),
		)
	end
end

encode(X::Line) = Rig("Line",
	location=X.p,
	"Direction"=>X.E,
)

encode(X::Plane) = Rig("Plane",
	location=X.p,
	"Normal"=>rdual(X.E),
)
