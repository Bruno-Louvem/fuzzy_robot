defmodule FuzzyRobot.Guards do
  defguard is_position(pos) when elem(pos, 0) > 0 and elem(pos, 1) > 0
  defguard is_dir(dir) when
    (dir == :south or dir == :north or dir == :east or dir == :west)
end
