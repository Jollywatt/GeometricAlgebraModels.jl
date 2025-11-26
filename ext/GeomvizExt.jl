module GeomvizExt

using GeometricAlgebra
using Geomviz.Pickle
import Geomviz: encode
using Geomviz: Rig

Pickle.List(x::GeometricAlgebra.StaticVector) = Pickle.List(collect(x))
Pickle.save(p::Pickle.AbstractPickle, io::IO, mv::Grade{1}) = Pickle.save(p, io, collect(Multivector(mv).comps))

encode(a::BasisBlade) = encode(Multivector(a))


include("vanilla.jl")
include("conformal.jl")

end