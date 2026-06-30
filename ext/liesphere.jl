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
