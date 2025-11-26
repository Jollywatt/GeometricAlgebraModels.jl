function dn end

samealgebra(X::AbstractMultivector{Sig}...) where Sig = X
samealgebra(X::AbstractMultivector...) = promote(X...)


"""
	translate(p)
	translate(p, X) -> X′ = sandwich_prod(translate(p), X)

Translation versor for the displacement vector `p::Grade{1}`.

The single-argument method returns the translation versor itself and
the two-argument form applies the versor to `X` with [`sandwich_prod`](@ref).

Different methods of `translate(p::Grade{1,Sig})` may exist for different algebras `Sig`.
The two-argument method embeds the vector `p` into the same space as `X`.
"""
function translate(p, X::AbstractMultivector{Sig}) where Sig
	p, X = samealgebra(p, X) # convert to same algebra
	sandwich_prod(translate(p), X)
end


function standardform end

standardform(a::BasisBlade) = standardform(Multivector(a))

function showformula end

function showfields(io::IO, X::T) where T
	indent = " "^get(io, :indent, 0)
	iszero(nfields(X)) && return
	pad = maximum(length.(string.(fieldnames(T))))
	for field in fieldnames(T)
		printstyled(io, "\n  ", indent, rpad(field, pad), color=:cyan, bold=true)
		print(io, " = ")
		val = getfield(X, field)
		if val isa Multivector
			GeometricAlgebra.show_multivector(io, val, inline=true, showzeros=false)
		elseif applicable(showformula, typeof(val))
			printstyled(io, indent, showformula(typeof(val)), color=:cyan)
			subio = IOContext(io, :indent => get(io, :indent, 0) + pad + 3)
			showfields(subio, val)
		else
			show(io, val)
		end
	end
end

# abstract type StandardFormMultivector{Sig,K} <: AbstractMultivector{Sig,K} end
abstract type StandardFormMultivector{Sig,K} end
GeometricAlgebra.grade(::StandardFormMultivector{Sig,K}) where {Sig,K} = K

function Base.show(io::IO, mime::MIME"text/plain", X::T) where T <: StandardFormMultivector
	println(io, T, ": ")
	print(io, " $(grade(X))-blade of the form ")
	printstyled(io, showformula(T), color=:cyan)
	print(io, ":")
	showfields(io, X)
end
