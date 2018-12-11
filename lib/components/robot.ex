defmodule FuzzyRobot.Component.Robot do
  alias FuzzyRobot.Component
  import FuzzyRobot.Guards

  defstruct left_sensor: 0,
            right_sensor: 0,
            front_sensor: 0,
            board: nil,
            sensor_distance: 10,
            compass: %{north: nil, south: :front_sensor, east: :right_sensor, west: :left_sensor},
            front_of: :south,
            current_position: nil

  def go(%Component.Robot{} = robot) do
    with {:ok, robot} <- read_sensors(robot),
         {:ok, robot} <- decide(robot)
    do
      {:ok, robot}
    end
  end

  def decide(%Component.Robot{} = robot) do
    robot.compass
    |> get_readble_directions()
    |> Enum.map(fn x ->
      value =
        robot |> Map.fetch!(robot.compass |> Map.fetch!(x))
      {x, value}
    end)

  end

  def calibrate_compass(%Component.Robot{} = robot) do
    compass =
      case robot.front_of do
        :north -> %{north: :front_sensor, south: nil, east: :right_sensor, west: :left_sensor}
        :south -> %{north: nil, south: :front_sensor, east: :left_sensor, west: :right_sensor}
        :east  -> %{north: :left_sensor, south: :right_sensor, east: :front_sensor, west: nil}
        :west  -> %{north: :right_sensor, south: :left_sensor, east: nil, west: :front_sensor}
      end
    %{robot| compass: compass}
  end

  def read_sensors(%Component.Robot{} = robot) do
    sensors =
      robot
      |> check_distance_on_board(robot.sensor_distance, robot.current_position)
      |> Enum.map(fn x -> x |> Enum.map(fn {k, v} -> %{k => v.distance} end) |> List.first end)
      |> Enum.reduce(%{}, fn x, acc -> acc |> Map.merge(x) end)

    {:ok, Map.merge(robot, sensors)}
  end

  def read_sensors(_), do: {:error, "Not Robot struct passed"}

  defp check_distance_on_board(%Component.Robot{} = robot, distance, position) do
    # {position_x, position_y} = position |> IO.inspect(label: "Initial position")
    robot.compass
    |> get_readble_directions()
    |> Enum.map(fn x ->
      x |> IO.inspect(label: "Checking positon: ")
      line = {position, Helpers.wk_dir(x, position, distance)}
      %{robot.compass[x] =>
        robot.board
        |> Component.Board.check_line(line)}
    end)
  end

  defp get_readble_directions(compass) do
    compass
    |> Map.keys
    |> Enum.filter(
        fn x ->
          compass
          |> Map.fetch!(x)
          |> is_nil() == false
      end)
  end

  defp go_to(%Component.Robot{} = robot, pos) when is_position(pos) do
    %{robot | current_position: pos}
    |> read_sensors()
  end

  defp go_to(%Component.Robot{} = robot, _pos) do
    {:error, robot}
  end

  def move(%Component.Robot{} = robot) do
    {:ok, robot} = read_sensors(robot)
    if validate_sensor(robot, robot.front_of, 1) do
      next_pos = Helpers.wk_dir(robot.front_of, robot.current_position, 1)
      go_to(robot, next_pos)
    else
      {:error, "Not possible move"}
    end
  end

  def move(%Component.Robot{} = robot, steps) when is_integer(steps) do
    {:ok, robot} = read_sensors(robot)
    if validate_sensor(robot, robot.front_of, steps) |> IO.inspect do
      next_pos = Helpers.wk_dir(robot.front_of, robot.current_position, steps)
      go_to(robot, next_pos)
    else
      {:error, "Not possible move"}
    end
  end

  # def move(%Component.Robot{} = robot, _), do: {:error, robot}

  def turn(%Component.Robot{} = robot, direction) when is_dir(direction) do
    %{robot | front_of: direction}
    |> calibrate_compass()
    |> read_sensors()
  end

  def turn(%Component.Robot{} = robot, _), do: {:error, robot}

  defp validate_sensor(%Component.Robot{} = robot, direction, distance) do
    sensor_value =
      case direction do
        :bottom -> robot.front_sensor
        :left -> robot.left_sensor
        :right -> robot.right_sensor
        _ -> robot.front_sensor
      end
      sensor_value >= distance
  end
end
