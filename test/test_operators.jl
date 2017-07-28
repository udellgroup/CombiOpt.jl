using CombiOpt
using FactCheck

TOL = 1e-3

facts("Operators") do

  context("Lovasz Extension") do
    # the Lovasz extension of a submodular function defined on a set of two elements
    function twodim(A::AbstractVector)
      if A == []
        return 0
      end
      if A == [1]
        return 3
      end
      if A == [2]
        return 2
      end
      if Set(A) == Set([1, 2])
        return 4
      end
    end
    w1 = [.5, 1]
    w2 = [1, .5]
    @fact lovaszext(twodim, w1) - dot([2, 2], w1) --> roughly(0, TOL)
    @fact lovaszext(twodim, w2) - dot([3, 1], w2) --> roughly(0, TOL)

    # the Lovasz extionsion of a modular function is a linear function
    c = rand(4)
    function modular(V::AbstractVector)
      if length(V) == 0
        return 0
      else
        return sum(c[V])
      end
    end
    A = [1, 2, 4]
    x = rand(3)
    @fact lovaszext(modular, x, A) - dot(c[A], x)  --> roughly(0, TOL)
  end

end