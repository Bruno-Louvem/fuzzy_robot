defmodule FuzzyRobot.Fuzzy.Engine do

  def relevance(point, ground, peak) when ground > peak, do: decrescent(point, ground, peak)
  def relevance(point, ground, peak), do: increscent(point, ground, peak)

  defp increscent(value, ground, _) when value <= ground, do: 0
  defp increscent(value, _, peak) when value >= peak, do: 1
  defp increscent(point, ground, peak), do: calc_relevance(point, ground, peak)

  defp decrescent(value, ground, _) when value >= ground, do: 0
  defp decrescent(value, _, peak) when value <= peak, do: 1
  defp decrescent(point, ground, peak), do: calc_relevance(point, ground, peak)

  defp calc_relevance(point, ground, peak), do: (ground - point)/(ground-peak)
end
