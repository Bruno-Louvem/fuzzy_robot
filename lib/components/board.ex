defmodule FuzzyRobot.Component.Board do
  defstruct position: {0,0}, width: 0, height: 0, objects: [], filled_positions: []

  alias FuzzyRobot.Component

  @doc """
    tuple_line it's a tuple of tuples that contains two internal tuples,
    the first is the initial position to be checked,
    and the second tuple is the final position to be checked e.g.: {{1, 1}, {1, 5}}
  """
  def check_line(board, tuple_line) do
    {start_post, _} = tuple_line
    dir = Helpers.get_dir(tuple_line)
    len = Helpers.get_len(dir, tuple_line)

    Helpers.get_all_pos_line(dir, len, start_post)
    |> check_l(board, {nil, 0})
    # |> Enum.map(fn position -> check_tile(board, position) end)
  end

  def check_l([pos | rest_line], board, {last_pos, counter}) do
    with  true <- inside_board?(board, pos),
          true <- !occupied_tile?(board, pos)
    do
      check_l(rest_line, board, {pos, counter + 1})
    else
      false -> check_l([], board, {last_pos, counter})
    end
  end

  def check_l([], _, {last_valid_pos, distance}) do
    %{last_valid_pos: last_valid_pos, distance: distance - 1}
  end

  def inside_board?(board, {x, y}) do
    {x0, y0} = board.position
    {x1, y1} = {x0 + (board.width + 1), y0 + (board.height + 1)}
    ((x0 < x and x1 > x) and (y0 < y and y1 > y))
  end

  def occupied_tile?(board, {x, y} = position) when x > 0 and y > 0 do
    board.filled_positions
    |> List.flatten
    |> Enum.any?(fn p -> p == position end)
  end

  def occupied_tile?(_, _), do: :true

  def add_object(%Component.Board{} = board, name, position, width, height) do

    name |> IO.inspect(label: "Board says - Adding object")
    position |> IO.inspect(label: "Board says - Position")
    width |> IO.inspect(label: "Board says - Width")
    height |> IO.inspect(label: "Board says - Height")

    {filled_positions, _} =
      0..(height - 1)
      |> Enum.map_reduce(position, fn _, acc ->
                    new_position = Helpers.wk_dir(:south, acc)
                    {Helpers.get_all_pos_line(:east, (width - 1), acc), new_position}
                  end)

    board.filled_positions ++ filled_positions
    |> IO.inspect(label: "Board says - Filled Positions")

    %{board |
        objects: board.objects ++ [%{name: name, width: width, height: height, position: position}],
        filled_positions: board.filled_positions ++ filled_positions
    }
  end
end
