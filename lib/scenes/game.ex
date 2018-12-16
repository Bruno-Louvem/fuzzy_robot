defmodule FuzzyRobot.Scene.Game do
  use Scenic.Scene

  alias Scenic.Graph
  alias Scenic.ViewPort
  alias FuzzyRobot.Component

  import Scenic.Primitives
  import FuzzyRobot.Guards

  @note """
    This is a simple robot based on fyzzy logic
  """

  # @graph Graph.build(font: :roboto, font_size: 24)
  # |> text(@note, translate: {10, 25})

  @frame_ms 32

  @empty_graph Graph.build(theme: :dark, font: :roboto, font_size: 18)

  @tile_size 40

  @board_size_width 20
  @board_size_height 20

  @robot_initial_position {1, 1}

  @exit_position_x 12
  @exit_position_y 20

  @wall_width 4
  @wall_height 1
  @wall_position_y 4
  @wall_position_x 1


  @header_panel_height 80
  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, opts) do
    # Get view port info
    viewport = opts[:viewport]

    # calculate the transform that centers the snake in the viewport
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    # Create a initial state for Board scruct
    board = Component.Board.build!(@board_size_width, @board_size_height)
            |> setup_wall() # Setup wall

    # Create Robot and set initial state
    robot = Component.Robot.build!(board, @robot_initial_position)

    {vp_tile_width, vp_tile_height} = calc_tile_by_viewport(vp_width, vp_height)

    graph = @empty_graph

    # start a very simple animation timer
    {:ok, timer} = :timer.send_interval(@frame_ms, :frame)

    state = %{
      viewport: viewport,
      tile_width: vp_tile_width,
      tile_height: vp_tile_height,
      graph: graph,
      frame_count: 1,
      frame_timer: timer,
      robot: robot,
      score: 0,
      # Game objects
      objects: %{robot: %{body: robot.current_position, front_of: robot.front_of},
                 wall: %{body: board.filled_positions |> List.flatten},
                 board: %{body: board_start_coords(board)}}
    }

    state.objects

    graph
    |> draw_objects(state.objects)
    |> push_graph()

    {:ok, state}
  end

  def handle_info(:frame, %{frame_count: frame_count} = state) do
    state = update_position_robot(state)

    state.graph |> draw_objects(state.objects) |> draw_panel(state.robot) |> push_graph()

    {:noreply, %{state | frame_count: frame_count + 1}}
  end

  def handle_input({:key, {" ", :press, _}}, _context, state) do
    {:noreply, update_robot(state)}
  end

  def handle_input({:key, {"up" = dir, :press, _}}, _context, state) do
    state |> move_robot_by_dir(dir)
  end

  def handle_input({:key, {"down" = dir, :press, _}}, _context, state) do
    state |> move_robot_by_dir(dir)
  end

  def handle_input({:key, {"left" = dir, :press, _}}, _context, state) do
    state |> move_robot_by_dir(dir)
  end

  def handle_input({:key, {"right" = dir, :press, _}}, _context, state) do
    state |> move_robot_by_dir(dir)
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

  defp move_robot_by_dir(state, dir) do
    compass_dir = Helpers.dir_to_compass(dir)
    state
    |> do_move_robot_by_dir(compass_dir == state.robot.front_of)

    if compass_dir == state.robot.front_of do
      state
      |> do_move_robot_by_dir()
    else
      state
      |> do_move_robot_by_dir(compass_dir)
    end
  end

  defp do_move_robot_by_dir(state) do
    case Component.Robot.move(state.robot) do
      {:ok, robot} -> {:noreply, state |> update_robot(robot)}
      _ -> {:noreply, state}
    end
  end

  defp do_move_robot_by_dir(state, compass_dir) do
    with {:ok, robot} <- Component.Robot.turn(state.robot, compass_dir),
         {:ok, robot} <- Component.Robot.move(robot)
    do
      {:noreply, state |> update_robot(robot)}
    else
      _ -> {:noreply, state}
    end
  end

  defp update_position_robot(state) do
    state
    |> put_in([:objects, :robot, :body], state.robot.current_position)
    |> put_in([:objects, :robot, :front_of], state.robot.front_of)
  end

  defp update_robot(state, robot) do
    state
    |> put_in([:robot], robot)
    |> update_position_robot()
  end

  defp update_robot(state) do
    {:ok, robot} = Component.Robot.go(state.robot)
    state
    |> put_in([:robot], robot)
    |> update_position_robot()
  end

  defp board_start_coords(board) do
    board_size = board.width + 1
    x = 0
    y = 2
    top = Helpers.get_all_pos_line(:east, board_size , {x, y})
    bottom = Helpers.get_all_pos_line(:east, board_size , {x, y + board_size})
    left = Helpers.get_all_pos_line(:south, @board_size_height , {x, y + 1})
    right = Helpers.get_all_pos_line(:south, @board_size_height , {x + board_size, y + 1})
    top ++ bottom ++ left ++ right
  end

  defp calc_tile_by_viewport(vp_width, vp_height) do
    width = trunc(vp_width / @tile_size) - 2
    height = trunc((vp_height - @header_panel_height) / @tile_size) - 2
    {width, height}
  end

  defp setup_wall(%Component.Board{} = board) do
    Component.Board.add_object(board, "wall", {@wall_position_x, @wall_position_y}, @wall_width, @wall_height)
  end

  defp draw_panel(graph, robot) do
    {x, y} = robot.current_position
    graph
    |> text("Position: {#{x}, #{y}}", fill: :white, translate: {@tile_size * 13, 20})
    |> text("Front of: #{robot.front_of |> Atom.to_string}", fill: :white, translate: {@tile_size * 13, 40})
    |> text("Sensors:", fill: :white, translate: {(@tile_size * 16) + 5, 20})
    |> text("Left Sensor: #{robot.left_sensor}",   fill: :white, translate: {@tile_size * 18, 20})
    |> text("Front Sensor: #{robot.front_sensor}", fill: :white, translate: {@tile_size * 18, 40})
    |> text("Right Sensor: #{robot.right_sensor}", fill: :white, translate: {@tile_size * 18, 60})
  end

  defp draw_objects(graph, object_map) do
    Enum.reduce(object_map, graph, fn {object_type, object_data}, graph ->
      draw_object(graph, object_type, object_data)
    end)
  end

  defp draw_object(graph, :board, %{body: board}) do
    Enum.reduce(board, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :dark_red)
    end)
  end

  defp draw_object(graph, :wall, %{body: wall}) do
    Enum.reduce(wall, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y + 2, fill: :purple)
    end)
  end

  defp draw_object(graph, :robot, %{body: {pos_x, pos_y}, front_of: front_of}) do
    graph
    |> draw_tile(pos_x, pos_y + 2, fill: :green)
    |> draw_sensors(pos_x, pos_y + 2, front_of)
  end

  defp draw_sensors(graph, x, y, front_of) do

    commom_opts = [fill: :red]

    left_opts   = [translate: sensor_position(front_of, :left, x, y)] |> Keyword.merge(commom_opts)
    right_opts  = [translate: sensor_position(front_of, :right, x, y)] |> Keyword.merge(commom_opts)
    bottom_opts = [translate: sensor_position(front_of, :front, x, y)] |> Keyword.merge(commom_opts)

    graph
    |> rect({10, 10}, left_opts)
    |> rect({10, 10}, right_opts)
    |> rect({10, 10}, bottom_opts)
  end

  defp sensor_position(:north, desired_sensor, x, y) do
    x_tile = x * @tile_size
    y_tile = y * @tile_size

    half_tile = @tile_size / 2
    quarter_tile = half_tile / 2
    one_third_tile = half_tile + quarter_tile

    case desired_sensor do
      :left  -> {x_tile, y_tile + one_third_tile / 2}
      :right -> {x_tile + one_third_tile, y_tile + one_third_tile / 2}
      :front -> {x_tile + one_third_tile / 2, y_tile}
    end
  end

  defp sensor_position(:south, desired_sensor, x, y) do
    x_tile = x * @tile_size
    y_tile = y * @tile_size

    half_tile = @tile_size / 2
    quarter_tile = half_tile / 2
    one_third_tile = half_tile + quarter_tile

    case desired_sensor do
      :left  -> {x_tile + one_third_tile, y_tile + one_third_tile / 2}
      :right -> {x_tile, y_tile + one_third_tile / 2}
      :front -> {x_tile + one_third_tile / 2, y_tile + one_third_tile}
    end
  end

  defp sensor_position(:east, desired_sensor, x, y) do
    x_tile = x * @tile_size
    y_tile = y * @tile_size

    half_tile = @tile_size / 2
    quarter_tile = half_tile / 2
    one_third_tile = half_tile + quarter_tile

    case desired_sensor do
      :left  -> {x_tile + one_third_tile / 2, y_tile}
      :right -> {x_tile + one_third_tile / 2, y_tile + one_third_tile}
      :front -> {x_tile + one_third_tile, y_tile + one_third_tile / 2}
    end
  end

  defp sensor_position(:west, desired_sensor, x, y) do
    x_tile = x * @tile_size
    y_tile = y * @tile_size

    half_tile = @tile_size / 2
    quarter_tile = half_tile / 2
    one_third_tile = half_tile + quarter_tile

    case desired_sensor do
      :left  -> {x_tile + one_third_tile / 2, y_tile + one_third_tile}
      :right -> {x_tile + one_third_tile / 2, y_tile}
      :front -> {x_tile, y_tile + one_third_tile / 2}
    end
  end

  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :white, translate: {x * @tile_size, y * @tile_size}], opts)
    graph |> rrect({@tile_size, @tile_size, 5}, tile_opts)
  end
end
