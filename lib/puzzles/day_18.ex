defmodule Day18 do
  import Advent2022

  @doc ~S"""
  --- Day 18: Boiling Boulders ---
  You and the elephants finally reach fresh air. You've emerged near the base of a large volcano that seems to be actively erupting! Fortunately, the lava seems to be flowing away from you and toward the ocean.

  Bits of lava are still being ejected toward you, so you're sheltering in the cavern exit a little longer. Outside the cave, you can see the lava landing in a pond and hear it loudly hissing as it solidifies.

  Depending on the specific compounds in the lava and speed at which it cools, it might be forming obsidian! The cooling rate should be based on the surface area of the lava droplets, so you take a quick scan of a droplet as it flies past you (your puzzle input).

  Because of how quickly the lava is moving, the scan isn't very good; its resolution is quite low and, as a result, it approximates the shape of the lava droplet with 1x1x1 cubes on a 3D grid, each given as its x,y,z position.

  To approximate the surface area, count the number of sides of each cube that are not immediately connected to another cube. So, if your scan were only two adjacent cubes like 1,1,1 and 2,1,1, each cube would have a single side covered and five sides exposed, a total surface area of 10 sides.

  Here's a larger example:

  #{test_input(:part_1)}
    #
  In the above example, after counting up all the sides that aren't connected to another cube, the total surface area is 64.

  What is the surface area of your scanned lava droplet?

  ## Example
    iex> part_1(test_input(:part_1))
    64
  """
  def_solution part_1(stream_input) do
    map = stream_input |> Stream.map(&parse/1) |> MapSet.new()

    map
    |> Enum.map(&visable_sides(map, &1))
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    58
  """
  def_solution part_2(stream_input) do
    map = stream_input |> Stream.map(&parse/1) |> MapSet.new()
    container = build_container(map)

    map
    |> Enum.map(&visable_sides(map, &1, container))
    |> Enum.sum()
  end

  @doc ~S"""
  ## Example
    iex> container = build_container(MapSet.new([{1, 1, 1}]))
    iex> MapSet.size(container)
    26
  """
  def build_container(map) do
    {{min_x, _, _}, {max_x, _, _}} = Enum.min_max_by(map, fn {x, _, _} -> x end)
    {{_, min_y, _}, {_, max_y, _}} = Enum.min_max_by(map, fn {_, y, _} -> y end)
    {{_, _, min_z}, {_, _, max_z}} = Enum.min_max_by(map, fn {_, _, z} -> z end)

    x_range = (min_x - 1)..(max_x + 1)
    x_range_reversed = (max_x + 1)..(min_x - 1)

    y_range = (min_y - 1)..(max_y + 1)
    y_range_reversed = (max_y + 1)..(min_y - 1)

    z_range = (min_z - 1)..(max_z + 1)
    z_range_reversed = (max_z + 1)..(min_z - 1)

    a =
      for y <- (min_y - 1)..(max_y + 1),
          z <- (min_z - 1)..(max_z + 1),
          reduce: MapSet.new() do
        acc ->
          a =
            x_range
            |> Stream.map(fn x -> {x, y, z} end)
            |> Stream.take_while(fn point -> not MapSet.member?(map, point) end)

          b =
            x_range_reversed
            |> Stream.map(fn x -> {x, y, z} end)
            |> Stream.take_while(fn point -> not MapSet.member?(map, point) end)

          a
          |> Stream.concat(b)
          |> MapSet.new()
          |> MapSet.union(acc)
      end

    b =
      for x <- (min_x - 1)..(max_x + 1),
          z <- (min_z - 1)..(max_z + 1),
          reduce: MapSet.new() do
        acc ->
          a =
            y_range
            |> Stream.map(fn y -> {x, y, z} end)
            |> Stream.take_while(fn point -> not MapSet.member?(map, point) end)

          b =
            y_range_reversed
            |> Stream.map(fn y -> {x, y, z} end)
            |> Stream.take_while(fn point -> not MapSet.member?(map, point) end)

          a
          |> Stream.concat(b)
          |> MapSet.new()
          |> MapSet.union(acc)
      end

    c =
      for x <- (min_x - 1)..(max_x + 1),
          y <- (min_y - 1)..(max_y + 1),
          reduce: MapSet.new() do
        acc ->
          a =
            z_range
            |> Stream.map(fn z -> {x, y, z} end)
            |> Stream.take_while(fn point -> not MapSet.member?(map, point) end)

          b =
            z_range_reversed
            |> Stream.map(fn z -> {x, y, z} end)
            |> Stream.take_while(fn point -> not MapSet.member?(map, point) end)

          a
          |> Stream.concat(b)
          |> MapSet.new()
          |> MapSet.union(acc)
      end

    a
    |> MapSet.union(b)
    |> MapSet.union(c)
  end

  defp visable_sides(map, {x, y, z}, container \\ nil) do
    [
      {x + 1, y, z},
      {x - 1, y, z},
      {x, y + 1, z},
      {x, y - 1, z},
      {x, y, z + 1},
      {x, y, z - 1}
    ]
    |> Enum.count(fn adjacent ->
      not MapSet.member?(map, adjacent) and
        (is_nil(container) or MapSet.member?(container, adjacent))
    end)
  end

  defp parse(line) do
    line
    |> String.split(",")
    |> then(fn [x, y, z] ->
      {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
    end)
  end

  def test_input(:part_1) do
    """
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
    """
  end
end
