```@raw html
<style>
figure img {
	width: 100%;
}
</style>
```


# Visualisation with Blender

The [`Geomviz`](https://github.com/jollywatt/geomviz) plugin for [`Blender`](https://www.blender.org/) may be used visualise, animate and render geometric objects created with `GeometricAlgebraModels.jl`.

`GeometricAlgebraModels.jl` includes a package extension which loads when the `Geomviz.jl` client is loaded.
The Julia client talks to the `Geomviz` Blender plugin and, and the package extension defines how geometric objects are transformed into "rigs" which get displayed in Blender.

## A simple example scene

Let's create a few random object in CGA:
```@example
using GeometricAlgebra, GeometricAlgebraModels.Conformal
circles = [wedge(up.(randn(Multivector{3,1}, 3))...) for _ in 1:5]
plane = first(circles) ∧ infinity()
nothing # hide
```

Then, make sure the `Geomviz` plugin is installed in Blender and is listening for data:

```@raw html
<figure>
<img src="../assets/listening.png" style="max-width: 400px;">
</figure>
```

Then, with `Geomviz` loaded in the Julia REPL, we can send the objects to Blender by pressing `space` at the start of the prompt or by calling `geomviz()`.

Hopefully, you should now see a scene similar to this in Blender's 3D viewport:

```julia-repl
julia> using Geomviz

geomviz> circles, plane # press space to enter geomviz REPL mode

julia> geomviz(circles, plane) # alternatively, pass objects to the plotting function
```

```@raw html
<figure>
<img src="../assets/scene-circles.png" style="max-width: calc(1358px / 2);">
</figure>
```

In the image above, the Viewport Shading settings had Object Colour set to Random.

## Object persistence

Each time you call `geomviz()` or enter something in the `geomviz>` REPL, the Blender scene is emptied and repopulated; objects do not persist.
If you want objects to stick around, you can store them in a vector and pass that to `geomviz()`, adding or removing objects as wanted.
Alternatively, you can write a script or function that creates objects and calls `geomviz()` at the end on a collection of all the objects at once.

## Styling

You can wrap objects in `Styled` to set their colour. For example, the following displays the point one unit above the origin in orange:
```julia
geomviz> Styled(up(0,0,1), color=(1,0.5,0,1))
```
