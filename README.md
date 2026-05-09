<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./docs/src/assets/logo-dark.svg">
  <img alt="logo" width="120" src="./docs/src/assets/logo.svg">
</picture>

# GeometricAlgebraModels.jl

This Julia package defines some _blade-based_ models of geometry with the [`GeometricAlgebra.jl`](https://github.com/jollywatt/GeometricAlgebra.jl) package and integrates with [`Geomviz`](https://github.com/jollywatt/geomviz) for visualisation with [`Blender`](https://www.blender.org/).

A blade-based model is a representation of geometric objects using blades (subspaces with oriented magnitude) of some larger vector space.

Currently, the following models are defined.

- **Conformal geometric algebra**, via the `Conformal` submodule.
