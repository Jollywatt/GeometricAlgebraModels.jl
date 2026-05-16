module MakieExt

using GeometricAlgebraModels.Conformal
import GeometricAlgebraModels: gaplot

function gaplot()
  println("herll0 ")
end

function gaplot(A::RoundGeometry{3, 3})
  (A.E, A.p)
end

end
