module GeometricAlgebraModels

using GeometricAlgebra
using LinearAlgebra
using StaticArrays

export standardform
export translate

export Projective
export Conformal
export Spacetime
export LieSphereGeometry

include("common.jl")
include("conformal.jl")
include("spacetime.jl")
include("opns.jl")
include("liesphere.jl")

function goo end

export gaplot
function gaplot end

end # module GeometricAlgebraModels
