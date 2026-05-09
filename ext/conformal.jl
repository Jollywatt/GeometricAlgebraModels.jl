using GeometricAlgebraModels.Conformal

#= encoding CGAGeometry subtypes =#

const Point = RoundGeometry{3,0}
const PointPair = RoundGeometry{3,1}
const Circle = RoundGeometry{3,2}
const Sphere = RoundGeometry{3,3}

const PointFlat = FlatGeometry{3,0}
const Line = FlatGeometry{3,1}
const Plane = FlatGeometry{3,2}

const TangentPoint = TangentBlade{3,0}
const TangentVector = TangentBlade{3,1}
const TangentPlane = TangentBlade{3,2}

encode(X::AbstractMultivector{<:CGA}) = encode(standardform(X))
encode(::Union{EmptySet,PointAtInfinity}) = Rig("Empty")

encode(X::FlatBlade) = encode(opns(X))
encode(X::DualFlatBlade) = encode(ipns(X))
function encode(X::RoundBlade)
	if abs(X.r2) < 1e-5
		encode(TangentBlade(X.E, X.p))
	else
		encode(X.r2 > 0 ? opns(X) : ipns(X))
	end
end

encode(X::Union{Point,PointFlat,TangentPoint})=  Rig("Point", location=X.p)

encode(X::TangentVector) = Rig("Arrow Vector",
	location=X.p,
	"Vector"=>X.E,
)

encode(X::PointPair) = Rig("Point Pair",
	location=X.p,
	"Direction"=>X.E,
	"Radius"=>√abs(X.r2),
	"Show bar"=>true,
	"Thickness"=>0.01,
	"Dashed"=>X.r2 < 0,
)

encode(X::Circle) = Rig("Circle",
	location=X.p,
	"Radius"=>√abs(X.r2),
	"Normal"=>rdual(X.E),
	"Dashed"=>X.r2 < 0,
	"Dash ratio"=>0.5,
)

encode(X::Line) = Rig("Line",
	location=X.p,
	"Direction"=>X.E,
)

encode(X::TangentPlane) = Rig("Spear Disk",
	location=X.p,
	"Radius"=>√abs(X.E⊙X.E),
	"Normal"=>rdual(X.E),
)

encode(X::Sphere) = Rig("Sphere",
	location=X.p,
	"Radius"=>√abs(X.r2),
	"Holes"=>X.r2 < 0,
)

encode(X::Plane) = Rig("Plane",
	location=X.p,
	"Normal"=>rdual(X.E),
)
