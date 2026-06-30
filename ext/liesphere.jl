using GeometricAlgebraModels.LieSphereGeometry
using GeometricAlgebraModels.LorentzianAlgebra

encode(A::OrientedPlane) = Rig("Plane", "Normal"=>A.n, location=A.n*A.d)
function encode(A::OrientedSphere)
  if abs(A.r) > 1e-2
    Rig("Sphere", location=A.p, "Radius"=>abs(A.r), "Holes"=>A.r < 0)
  else
    Rig("Point", location=A.p)
  end
end

function encode(A::TangentBlade{Lorentzian{3}, 0})
  p, r = spacetimesplit(A.p)
  encode(OrientedSphere(p, r))
end

function encode(A::RoundBlade{Lorentzian{3}, 3})
  p, t = spacetimesplit(A.p)
  v0 = timevector()

  perp = embed(Val(3), inner(A.E, v0))
  n = inner(inv(perp), embed(Val(3), inner(wedge(A.E, v0), v0)))

  c2 = scalar_prod(n, n) - 1
  if c2 >= 0
    Rig(
      "Dupin Cyclide",
      location=p,
      "x axis"=>n,
      "y axis"=>perp,
      "b"=>√A.r2,
      "c"=>-1/√c2,
      "d"=>t,
    )
  else
    encode(opns(Multivector(A)))
  end
end
