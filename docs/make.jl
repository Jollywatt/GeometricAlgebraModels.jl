using Documenter
using DocumenterInterLinks
using GeometricAlgebraModels

pushfirst!(LOAD_PATH, joinpath(@__DIR__, ".."))

# apply setup code to all doctests in doc strings
DocMeta.setdocmeta!(GeometricAlgebraModels, :DocTestSetup, quote
    using GeometricAlgebraModels
    using GeometricAlgebraModels.GeometricAlgebra
end; recursive=true)

links = InterLinks(
	"GeometricAlgebra" => "https://jollywatt.github.io/GeometricAlgebra.jl/dev/",
)


makedocs(
    sitename = "GeometricAlgebraModels.jl",
    format = Documenter.HTML(),
    modules = [GeometricAlgebraModels],
    repo = Remotes.GitHub("jollywatt", "GeometricAlgebraModels.jl"),
    plugins = [links],
    pages = Any[
    	"index.md",
    	"Models" => ["cga.md"],
    	"blender.md",
    	"docstrings.md",
		],
)

deploydocs(
    repo = "git@github.com:Jollywatt/GeometricAlgebraModels.jl.git"
)
