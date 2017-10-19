#############################################################################
# modular.jl
# Handles modular functions of a given vector x.
#############################################################################

export modular
export lovasz
export sign, monotonicity, modularity, evaluate

type ModularAtom <: CombiFunc   # TODO: extend to sets other than plain set varables
  head::Symbol
  id_hash::UInt64
  children::Tuple{AbstractExpr, CombiSet}
  size::Tuple{Int, Int}
  param::AbstractExpr
  setvariables::Array{CombiSet}

  function ModularAtom(x::AbstractExpr, S::CombiSet)
    if x.size != (S.cardinality, 1)
      error("Cannot define a modular function when the vector's size is different from the (card(baseset), 1).")
    else
      children = (x, S)
      setvariables = get_sv(S)
      return new(:modular, hash(children), children, (1, 1), x, setvariables)
    end
  end
end

modular(x::Variable, S::CombiSet) = ModularAtom(x, S)

modular(x::Val, S::CombiSet) = ModularAtom(Constant(x), S)

function lovasz(F::ModularAtom, x::Variable)
  if length(F.setvariables) == 1
    if evaluate(F, [])[1] != 0
      error("A combinatorial function should be 0 at the empty set to derive its Lovasz extension.")
    else
      if x.size[1] == F.setvariables[1].cardinality
        if isa(F.children[2], SetVariable)
          return vecdot(F.children[1], x)
        else
          return LovaszExtAtom(F, x)
        end
      else
        error("The size of the continuous variable should be the same as the baseset of the combinatorial variable of the combinatorial function.")
      end
    end
  else
    error("A combinatorial function should be sigle-variant to obtain its Lovasz extension.")
  end
end

function lovasz(F::ModularAtom, x::AbsAtom)
  if length(F.setvariables) == 1
    if length(x.children) == 1 && isa(x.children[1], Variable)
      if evaluate(F, [])[1] != 0
        error("A combinatorial function should be 0 at the empty set to derive its Lovasz extension.")
      else
        var = get_v(x)
        if length(var) != 1
          error("Functions with other than one variable are not supported.")
        else
          if var[1].size[1] == F.setvariables[1].cardinality
            if isa(F.children[2], SetVariable)
              return vecdot(F.children[1], x)
            else
              return LovaszExtAbsAtom(F, x)
            end
          else
            error("The size of the continuous variable should be the same as the baseset of the combinatorial variable of the combinatorial function.")
          end
        end
      end
    else
      error("Only able to define Lovasz extesions on absolute values of a variable.")
    end
  else
    error("A combinatorial function should be sigle-variant to obtain its Lovasz extension.")
  end
end


function sign(F::ModularAtom)
  return sign(F.children[1]) * sign(F.children[2])
end

function monotonicity(F::ModularAtom)
  return (sign(F.children[2]) * Nondecreasing(), sign(F.children[1]) * Nondecreasing())
end

function modularity(F::ModularAtom)
  return Modularity()
end

function evaluate(F::ModularAtom) # TODO only allow scalar input
  summ = 0.0
  param = evaluate(F.param)
  elements = []
  elements = vcat(elements, get_elements(F.children[2]))
  elements = Set(elements)
  for i in elements
    summ += param[i]
  end
  # Compatibility with Convex.jl
  val = zeros(1, 1)
  val[1] = summ
  return val
end
