using Documenter
using GeometricAlgebraModels

pushfirst!(LOAD_PATH, joinpath(@__DIR__, ".."))

# apply setup code to all doctests in doc strings
DocMeta.setdocmeta!(GeometricAlgebraModels, :DocTestSetup, quote
    using GeometricAlgebraModels
    using GeometricAlgebraModels.GeometricAlgebra
end; recursive=true)


makedocs(
    sitename = "GeometricAlgebraModels",
    format = Documenter.HTML(),
    modules = [GeometricAlgebraModels],
    repo = Remotes.GitHub("jollywatt", "GeometricAlgebraModels.jl")
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
