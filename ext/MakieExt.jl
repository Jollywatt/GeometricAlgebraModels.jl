module MakieExt

using Makie
import Makie: convert_arguments

using Makie.GeometryBasics

using GeometricAlgebra
using GeometricAlgebraModels.Conformal
import GeometricAlgebraModels: gaplot

Base.convert(T::Type{<:Union{Point,Vec}}, a::Grade{1}) = convert(T, a.comps)

function tomesh(A::RoundGeometry{Sig,K}; npoints=24) where {Sig,K}

  # to convert a k-round into a mesh, start with GeometryBasics's tessellation of a HyperSphere in k-dimensions
  # and then embed this into n >= k dimensional space, then rotate and translate

  gavec(x) = embed(Sig, Multivector{length(x),1}(x))

  hypersphere = HyperSphere(zero(Point{K,Float64}), √A.r2)
  mesh = normal_mesh(Tessellation(hypersphere, npoints))

  horizon_blade = basis(Sig, K, 1)
  target_blade = A.E
  rotor = sqrt(target_blade/horizon_blade)
  rotor /= √(rotor⊙~rotor)

  @show mesh

  N = dimension(Sig)
  verts = convert.(Point{N}, sandwich_prod.(rotor, gavec.(mesh.position)) .+ A.p)
  normal = convert.(Vec{N}, sandwich_prod.(rotor, gavec.(mesh.normal)))

  GeometryBasics.Mesh(verts, mesh.faces; normal)
end


const MeshOrWire = Union{Makie.Mesh,Makie.Wireframe}
Makie.used_attributes(::Type{<:MeshOrWire}, ::CGAGeometry) = (:npoints,)
function convert_arguments(MT::Type{<:MeshOrWire}, A::RoundGeometry{Sig,K}; npoints=24) where {Sig,K}
  return convert_arguments(MT, tomesh(A; npoints))
end

end
