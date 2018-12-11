defmodule RobotServer do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(robot) do
    {:ok, robot}
  end

  def handle_call({:move, steps}, _, state) do
    case FuzzyRobot.Component.Robot.move(state, steps) do
      {:ok, robot} ->
        {:reply, {:ok, robot}, robot}
      {:error, message} ->
        {:reply, {:error, message}, state}
    end
  end

  def handle_call({:turn, direction}, _, state) do
    case FuzzyRobot.Component.Robot.turn(state, direction) do
      {:ok, robot} ->
        {:reply, {:ok, robot}, robot}
      {:error, message} ->
        {:reply, {:error, message}, state}
    end
  end
end
