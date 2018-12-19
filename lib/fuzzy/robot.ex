defmodule FuzzyRobot.Fuzzy.Sets do
  import FuzzyRobot.Fuzzy.Engine

  @near_set {6, 0}
  @far_set {4, 10}

  def near(value), do: value |> relevance_set(@near_set)
  def far(value), do: value |> relevance_set(@far_set)

  def relevance_set(value, {ground, peak}), do: relevance(value, ground, peak)
end
