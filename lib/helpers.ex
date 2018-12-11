defmodule Helpers do
  def wk_dir(:south, {x, y}), do: {x, y + 1}
  def wk_dir(:north, {x, y}), do: {x, y - 1}
  def wk_dir(:west, {x, y}), do: {x - 1, y}
  def wk_dir(:east, {x, y}), do: {x + 1, y}

  def wk_dir(:south, {x, y}, len), do: {x, y + len}
  def wk_dir(:north, {x, y}, len), do: {x, y - len}
  def wk_dir(:west, {x, y}, len), do: {x - len, y}
  def wk_dir(:east, {x, y}, len), do: {x + len, y}

  def get_dir({{x1, _}, {x2, _}}) when x1 < x2, do: :east
  def get_dir({{x1, _}, {x2, _}}) when x1 > x2, do: :west
  def get_dir({{_, y1}, {_, y2}}) when y1 < y2, do: :south
  def get_dir({{_, y1}, {_, y2}}) when y1 > y2, do: :north

  def get_len(:east,  {{x1, _}, {x2, _}}), do: x2 - x1
  def get_len(:west,   {{x1, _}, {x2, _}}), do: x1 - x2
  def get_len(:south, {{_, y1}, {_, y2}}), do: y2 - y1
  def get_len(:north,    {{_, y1}, {_, y2}}), do: y1 - y2

  def get_all_pos_line(dir, len, start_pos) do
    0..len
    |> Enum.map_reduce(start_pos,
      fn _, last_pos ->
        cur_pos = wk_dir(dir, last_pos)
        {last_pos, cur_pos}
      end)
    |> elem(0)
  end

end
