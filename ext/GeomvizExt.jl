module GeomvizExt

using GeometricAlgebra
using GeometricAlgebraModels: Mesh
using Geomviz.Pickle
import Geomviz: encode
using Geomviz: Rig

Pickle.List(x::GeometricAlgebra.StaticVector) = Pickle.List(collect(x))
Pickle.save(p::Pickle.AbstractPickle, io::IO, mv::Grade{1}) = Pickle.save(p, io, collect(Multivector(mv).comps))

encode(a::BasisBlade) = encode(Multivector(a))

include("vanilla.jl")
include("conformal.jl")
include("liesphere.jl")

encode(a::Mesh) = Rig("Mesh",
	vertices=a.vertices,
	edges=[e .- 1 for e in a.edges],
	faces=[f .- 1 for f in a.faces],
	"Shade Smooth"=>true,
	"Show Edges"=>true,
)

end
