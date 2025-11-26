using GeometricAlgebraModels.LieSphereGeometry

encode(A::OrientedPlane) = Rig("Plane", "Normal"=>A.n, location=A.n*A.d)
function encode(A::OrientedSphere)
  if abs(A.r) > 1e-2
    Rig("Sphere", location=A.p, "Radius"=>abs(A.r), "Holes"=>A.r < 0)
  else
    Rig("Point", location=A.p)
  end
end
