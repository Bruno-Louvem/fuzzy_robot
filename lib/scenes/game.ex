defmodule FuzzyRobot.Scene.Game do
  use Scenic.Scene

  alias Scenic.Graph
  alias FuzzyRobot.Component

  import Scenic.Primitives

  @note """
    This is a simple robot based on fyzzy logic
  """

  @graph Graph.build(font: :roboto, font_size: 24)
  |> text(@note, translate: {10, 25})

  @tile_size 40
  @board_size_width 20
  @board_size_height 20

  @robot_initial_position {1, 1}
  @robot_initial_orientation "BOTTOM"

  @exit_position_x 12
  @exit_position_y 20

  @wall_width 3
  @wall_height 3
  @wall_position_y 3
  @wall_position_x 1

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _) do
    # Create a initial state for Board scruct
    board =
      %Component.Board{width: @board_size_width, height: @board_size_height}
      |> setup_wall() # Setup wall

    # Create Robot and set initial state
    robot = %Component.Robot{board: board, current_position: @robot_initial_position}

    push_graph( @graph )
    {:ok, @graph}
  end

  defp setup_wall(%Component.Board{} = board) do
    Component.Board.add_object(board, "wall", {@wall_position_x, @wall_position_y}, @wall_width, @wall_height)
  end
end
