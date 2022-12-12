defmodule Day12 do
  import Advent2022

  @doc ~S"""
  --- Day 12: Hill Climbing Algorithm ---
  You try contacting the Elves using your handheld device, but the river you're following must be too low to get a decent signal.

  You ask the device for a heightmap of the surrounding area (your puzzle input). The heightmap shows the local area from above broken into a grid; the elevation of each square of the grid is given by a single lowercase letter, where a is the lowest elevation, b is the next-lowest, and so on up to the highest elevation, z.

  Also included on the heightmap are marks for your current position (S) and the location that should get the best signal (E). Your current position (S) has elevation a, and the location that should get the best signal (E) has elevation z.

  You'd like to reach E, but to save energy, you should do it in as few steps as possible. During each step, you can move exactly one square up, down, left, or right. To avoid needing to get out your climbing gear, the elevation of the destination square can be at most one higher than the elevation of your current square; that is, if your current elevation is m, you could step to elevation n, but not to elevation o. (This also means that the elevation of the destination square can be much lower than the elevation of your current square.)

  For example:

  #{test_input(:part_1)}

  Here, you start in the top-left corner; your goal is near the middle. You could start by moving down or right, but eventually you'll need to head toward the e at the bottom. From there, you can spiral around to the goal:

  v..v<<<<
  >v.vv<<^
  .>vv>E^^
  ..v>>>^^
  ..>>>>>^

  In the above diagram, the symbols indicate whether the path exits each square moving up (^), down (v), left (<), or right (>). The location that should get the best signal is still E, and . marks unvisited squares.

  This path reaches the goal in 31 steps, the fewest possible.

  What is the fewest steps required to move from your current position to the location that should get the best signal?

  ## Example
    iex> part_1(test_input(:part_1))
    31
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> then(fn %{current: current, board: board, final: final} ->
      breadth_first_search(board, final, [[current]], MapSet.new([current]))
    end)
    |> score()
  end

  @doc ~S"""
  --- Part Two ---
  As you walk up the hill, you suspect that the Elves will want to turn this into a hiking trail. The beginning isn't very scenic, though; perhaps you can find a better starting point.

  To maximize exercise while hiking, the trail should start as low as possible: elevation a. The goal is still the square marked E. However, the trail should still be direct, taking the fewest steps to reach its goal. So, you'll need to find the shortest path from any square at elevation a to the square marked E.

  Again consider the example from above:

  Sabqponm
  abcryxxl
  accszExk
  acctuvwj
  abdefghi
  Now, there are six choices for starting position (five marked a, plus the square marked S that counts as being at elevation a). If you start at the bottom-left square, you can reach the goal most quickly:

  ...v<<<<
  ...vv<<^
  ...v>E^^
  .>v>>>^^
  >^>>>>>^
  This path reaches the goal in only 29 steps, the fewest possible.

  What is the fewest steps required to move starting from any square with elevation a to the location that should get the best signal?
  ## Example
    iex> part_2(test_input(:part_1))
    29
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> then(fn %{board: board, final: final} ->
      starting_points = get_starting_points(board)

      breadth_first_search(
        board,
        final,
        Enum.map(starting_points, &List.wrap/1),
        MapSet.new(starting_points)
      )
    end)
    |> score()
  end

  defp get_starting_points(board) do
    Enum.flat_map(board, fn
      {key, 0} -> [key]
      _ -> []
    end)
  end

  defp score(path), do: length(path) - 1

  defp breadth_first_search(board, final, [_ | _] = paths, visited) do
    Enum.reduce(paths, {[], visited}, fn [current | _rest] = path, {paths_acc, visited_acc} ->
      next_locations = steps(board, current, visited_acc)
      if(final in next_locations, do: throw([final | path]))
      next_paths = Enum.map(next_locations, fn loc -> [loc | path] end)

      {next_paths ++ paths_acc, MapSet.union(visited_acc, MapSet.new(next_locations))}
    end)
    |> then(fn {updated_paths, updated_visited} ->
      breadth_first_search(board, final, updated_paths, updated_visited)
    end)
  catch
    shortest_path -> shortest_path
  end

  defp steps(board, location, visited) do
    location_heigh = board[location]

    location
    |> adjacent()
    |> Enum.filter(fn adjacent ->
      possible_step(board, location_heigh, adjacent) and adjacent not in visited
    end)
  end

  defp possible_step(board, current_height, location) do
    height = board[location]

    is_integer(height) and height <= current_height + 1
  end

  defp adjacent({x, y}) do
    [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]
  end

  defp parse(stream_input) do
    for {line, y} <- Enum.with_index(stream_input),
        {cell, x} <- line |> String.graphemes() |> Enum.with_index(),
        reduce: %{current: nil, board: %{}, final: nil} do
      state ->
        loc = {x, y}

        %{
          current: if(cell == "S", do: loc, else: state.current),
          final: if(cell == "E", do: loc, else: state.final),
          board: Map.put(state.board, loc, val(cell))
        }
    end
  end

  defp val("S"), do: val("a")
  defp val("E"), do: val("z")
  defp val(val), do: (to_charlist(val) |> List.first()) - 97

  def test_input(:part_1) do
    """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """
  end
end

