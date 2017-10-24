using CombiOpt, LightGraphs
using FactCheck

Tol = 1e-3

facts("Submodular Functions") do

  context("card-based atom") do
    A = SetVariable(3)
    F = card(A)
    @fact evaluate(F, [1, 3]) --> roughly(2, Tol)

    p(z) = -0.5*z^2 + 3*z + 0.5 * z
    perm_func = compose(p, F)
    @fact modularity(perm_func) --> SubModularity()
    @fact evaluate(perm_func, [1, 2, 3])[1] --> roughly(6, Tol)
  end

  context("cut atom") do
    A = SetVariable(3)
    G = Graph(3)
    add_edge!(G, 1, 3)
    F = cut(G, A)
    @fact modularity(F) --> SubModularity()
    @fact evaluate(F, [1, 2]) --> roughly(1, Tol)
  end

  context("modular atom") do
    A = SetVariable(4)
    F = modular([1, 2, 3, 4], A)
    @fact modularity(F) --> Modularity()
    @fact evaluate(F, [1, 3]) --> roughly(4, Tol)
  end

  context("rank of graph matroid atom") do
    A = SetVariable(2)
    G = Graph(3)
    add_edge!(G, 1, 3)
    add_edge!(G, 2, 3)
    F = rank_of_graph_matroid(G, A)
    @fact modularity(F) --> SubModularity()
    @fact evaluate(F, [1, 2]) --> roughly(2, Tol)
  end

end
