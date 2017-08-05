#############################################################################
# polyhedra.jl
# Handles constraints specifying the feasible region to be polyhedra
# associated with a submodular function f: 2ⱽ → ℝ, where V is the base set.
# The included polyhedra are:
## The submodular polyhedron: SubPoly = {s ∈ ℝᵖ, ∀ A ⊆ V, s(A) ≤ F(A)}.
## The base polyhedron: BasePoly = {s ∈ ℝᵖ, s(V) = F(V), ∀ A ⊆ V, s(A) ≤ F(A)}
##                               = subpoly ∩ {s(V) = F(v)}.
## The positive polyhedron: PosPoly = {s ∈ ℝᵖ₊, ∀ A ⊆ V, s(A) ≤ F(A)}
##                                  = subpoly ∩ ℝᵖ₊.
## The symmetric submodular polyhedron: SymPoly = {s ∈ ℝᵖ, ∀ A ⊆ V, |s|(A) ≤ F(A)}
##                                              = {s ∈ ℝᵖ, |s| ∈ subpoly}.
# Here p = |V|, i.e. the cardinality of the base set.
#############################################################################

import Base.in
export AssPoly
export SubPoly, BasePoly, PosPoly, SymPoly
export in, fenchel

abstract type AssPoly <: CombiSet end

type SubPoly{T} <: AssPoly
  f::T              # the submodular function
  V::AbstractVector # indexes of the base set
end

function SubPoly{T}(f::T, V::AbstractVector)
  @assert f([]) == 0
  return SubPoly(f, V)
end

function SubPoly{T}(f::T, n::Int)
  # @assert f([]) == 0
  return SubPoly(f, collect(1:n))
end

type BasePoly{T} <: AssPoly
  f::T
  V::AbstractVector
end

# function BasePoly{T}(f::T, V::AbstractVector)
#   @assert f([]) == 0
#   return BasePoly(f, V)
# end

function BasePoly{T}(f::T, n::Int)
  # @assert f([]) == 0
  return BasePoly(f, collect(1:n))
end

type PosPoly{T} <: AssPoly
  f::T
  V::AbstractVector
end

# function PosPoly{T}(f::T, V::AbstractVector)
#   @assert f([]) == 0
#   return PosPoly(f, V)
# end

function PosPoly{T}(f::T, n::Int)
  # @assert f([]) == 0
  return PosPoly(f, collect(1:n))
end

type SymPoly{T} <: AssPoly
  f::T
  V::AbstractVector
end

# function SymPoly{T}(f::T, V::AbstractVector)
#   @assert f([]) == 0
#   return SymPoly(f, V)
# end

function SymPoly{T}(f::T, n::Int)
  # @assert f([]) == 0
  return SymPoly(f, collect(1:n))
end

# check if w is in p

function in(w::AbstractVector, p::AssPoly)
  n = length(w)
  @assert length(p.V) == n
  x = prox(p, w)
  if sum(abs.(x - w)) < TOL
    return true
  else
    return false
  end
end

# compute min w^x st x in p

# fenchel(p, w) = greedy(p.f, -w, p.V), w is nonpositve,
#               = -Inf,                 w is not nonpositive
function fenchel(p::SubPoly, w::AbstractVector)
  n = length(w)
  @assert length(p.V) == n
  if any(x -> x>0, w)
    return -Inf
  else
    return greedy(p.f, -w, p.V)
  end
end

# fenchel(p, w) = greedy(p.f, -w, p.V)
function fenchel(p::BasePoly, w::AbstractVector)
  n = length(w)
  @assert length(p.V) == n
  return greedy(p.f, -w, p.V)
end

# fenchel(p, w) = -sign(w_{-}) * greedy(p.f, -w_{-}, p.V)
function fenchel(p::PosPoly, w::AbstractVector)
  n = length(w)
  @assert length(p.V) == n
  u = 0.5 * (w - abs.(w))
  v = greedy(p.f, -u, p.V)
  v = -sign.(u) .* v
  return v
end

# fenchel(p, w) = -sign(w) .* greedy(p.f, |w|, p.V)
function fenchel(p::SymPoly, w::AbstractVector)
  n = length(w)
  @assert length(p.V) == n
  v = greedy(p.f, abs.(w), p.V)
  v = -sign.(w) .* v
  return v
end
