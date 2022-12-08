defmodule Day8 do
  import Advent2022

  @doc ~S"""
  --- Day 8: Treetop Tree House ---
  The expedition comes across a peculiar patch of tall trees all planted carefully in a grid. The Elves explain that a previous expedition planted these trees as a reforestation effort. Now, they're curious if this would be a good location for a tree house.

  First, determine whether there is enough tree cover here to keep a tree house hidden. To do this, you need to count the number of trees that are visible from outside the grid when looking directly along a row or column.

  The Elves have already launched a quadcopter to generate a map with the height of each tree (your puzzle input). For example:

  #{test_input(:part_1)}

  Each tree is represented as a single digit whose value is its height, where 0 is the shortest and 9 is the tallest.

  A tree is visible if all of the other trees between it and an edge of the grid are shorter than it. Only consider trees in the same row or column; that is, only look up, down, left, or right from any given tree.

  All of the trees around the edge of the grid are visible - since they are already on the edge, there are no trees to block the view. In this example, that only leaves the interior nine trees to consider:


  - The top-left 5 is visible from the left and top. (It isn't visible from the right or bottom since other trees of height 5 are in the way.)
  - The top-middle 5 is visible from the top and right.
  - The top-right 1 is not visible from any direction; for it to be visible, there would need to only be trees of height 0 between it and an edge.
  - The left-middle 5 is visible, but only from the right.
  - The center 3 is not visible from any direction; for it to be visible, there would need to be only trees of at most height 2 between it and an edge.
  - The right-middle 3 is visible from the right.
  - In the bottom row, the middle 5 is visible, but the 3 and 4 are not.

  With 16 trees visible on the edge and another 5 visible in the interior, a total of 21 trees are visible in this arrangement.

  Consider your map; how many trees are visible from outside the grid?

  ## Example
    iex> part_1(test_input(:part_1))
    21
  """
  def_solution part_1(stream_input) do
    forrest = to_grid(stream_input)

    forrest
    |> get_visable_trees()
    |> map_size()
  end

  @doc """
  --- Part Two ---
  Content with the amount of tree cover available, the Elves just need to know the best spot to build their tree house: they would like to be able to see a lot of trees.

  To measure the viewing distance from a given tree, look up, down, left, and right from that tree; stop if you reach an edge or at the first tree that is the same height or taller than the tree under consideration. (If a tree is right on the edge, at least one of its viewing distances will be zero.)

  The Elves don't care about distant trees taller than those found by the rules above; the proposed tree house has large eaves to keep it dry, so they wouldn't be able to see higher than the tree house anyway.

  In the example above, consider the middle 5 in the second row:

  30373
  25512
  65332
  33549
  35390
  Looking up, its view is not blocked; it can see 1 tree (of height 3).
  Looking left, its view is blocked immediately; it can see only 1 tree (of height 5, right next to it).
  Looking right, its view is not blocked; it can see 2 trees.
  Looking down, its view is blocked eventually; it can see 2 trees (one of height 3, then the tree of height 5 that blocks its view).

  A tree's scenic score is found by multiplying together its viewing distance in each of the four directions. For this tree, this is 4 (found by multiplying 1 * 1 * 2 * 2).

  However, you can do even better: consider the tree of height 5 in the middle of the fourth row:

  30373
  25512
  65332
  33549
  35390
  Looking up, its view is blocked at 2 trees (by another tree with a height of 5).
  Looking left, its view is not blocked; it can see 2 trees.
  Looking down, its view is also not blocked; it can see 1 tree.
  Looking right, its view is blocked at 2 trees (by a massive tree of height 9).
  This tree's scenic score is 8 (2 * 2 * 1 * 2); this is the ideal spot for the tree house.

  Consider each tree on your map. What is the highest scenic score possible for any tree?

  ## Example
    iex> part_2(test_input(:part_1))
    8
  """
  def_solution part_2(stream_input) do
    forrest = to_grid(stream_input)

    forrest
    |> Stream.map(&to_scenic_distance(forrest, &1))
    |> Enum.max()
  end

  defp to_scenic_distance(forrest, {key, high_point}) do
    [:left, :right, :top, :bottom]
    |> Enum.map(fn dir ->
      change = count_dir(dir)

      count_visable_trees(forrest, add(key, change), change, high_point, 0)
    end)
    |> Enum.product()
  end

  defp get_visable_trees(forrest) do
    forrest
    |> get_edges()
    |> prepare_for_counting()
    |> Stream.map(fn {key, change} ->
      build_visable_stripe(forrest, key, change, -1, %{})
    end)
    |> Enum.reduce(&Map.merge/2)
  end

  defp count_visable_trees(forrest, key, change, high_point, acc) do
    case Map.get(forrest, key) do
      nil ->
        acc

      tall when tall >= high_point ->
        acc + 1

      _short ->
        count_visable_trees(forrest, add(key, change), change, high_point, acc + 1)
    end
  end

  defp build_visable_stripe(forrest, key, change, high_point, acc) do
    case Map.get(forrest, key) do
      nil ->
        acc

      short when short <= high_point ->
        build_visable_stripe(forrest, add(key, change), change, high_point, acc)

      tall ->
        build_visable_stripe(
          forrest,
          add(key, change),
          change,
          max(high_point, tall),
          Map.put(acc, key, tall)
        )
    end
  end

  defp prepare_for_counting(edges) do
    for {key, edge} <- edges, tree <- edge do
      {tree, count_dir(key)}
    end
  end

  def count_dir(:top), do: {1, 0}
  def count_dir(:bottom), do: {0, -1}
  def count_dir(:left), do: {0, 1}
  def count_dir(:right), do: {-1, 0}

  defp get_edges(forrest) do
    top = get_edge(forrest, {0, 0}, {0, 1}, [])
    left = get_edge(forrest, {0, 0}, {1, 0}, [])

    max_x = length(top) - 1
    max_y = length(left) - 1

    bottom = get_edge(forrest, {0, max_y}, {1, 0}, [])
    right = get_edge(forrest, {max_x, 0}, {0, 1}, [])

    %{top: top, bottom: bottom, left: left, right: right}
  end

  defp get_edge(forrest, key, change, acc) do
    if Map.has_key?(forrest, key) do
      get_edge(forrest, add(key, change), change, [key | acc])
    else
      acc
    end
  end

  defp add({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp to_grid(stream_input) do
    stream_input
    |> Stream.with_index()
    |> Stream.map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Map.new(fn {tree, x} -> {{x, y}, String.to_integer(tree)} end)
    end)
    |> Enum.reduce(&Map.merge/2)
  end

  def test_input(:part_1) do
    """
    30373
    25512
    65332
    33549
    35390
    """
  end
end

