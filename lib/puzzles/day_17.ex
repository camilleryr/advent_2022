defmodule Day17 do
  import Advent2022

  @doc ~S"""
  --- Day 17: Pyroclastic Flow ---
  Your handheld device has located an alternative exit from the cave for you and the elephants.  The ground is rumbling almost continuously now, but the strange valves bought you some time. It's definitely getting warmer in here, though.

  The tunnels eventually open into a very tall, narrow chamber. Large, oddly-shaped rocks are falling into the chamber from above, presumably due to all the rumbling. If you can't work out where the rocks will fall next, you might be crushed!

  The five types of rocks have the following peculiar shapes, where # is rock and . is empty space:

  ####

  .#.
  ###
  .#.

  ..#
  ..#
  ###

  #
  #
  #
  #

  ##
  ##

  The rocks fall in the order shown above: first the - shape, then the + shape, and so on. Once the end of the list is reached, the same order repeats: the - shape falls first, sixth, 11th, 16th, etc.

  The rocks don't spin, but they do get pushed around by jets of hot gas coming out of the walls themselves. A quick scan reveals the effect the jets of hot gas will have on the rocks as they fall (your puzzle input).

  For example, suppose this was the jet pattern in your cave:

  #{test_input(:part_1)}

  In jet patterns, < means a push to the left, while > means a push to the right. The pattern above means that the jets will push a falling rock right, then right, then right, then left, then left, then right, and so on. If the end of the list is reached, it repeats.

  The tall, vertical chamber is exactly seven units wide. Each rock appears so that its left edge is two units away from the left wall and its bottom edge is three units above the highest rock in the room (or the floor, if there isn't one).

  After a rock appears, it alternates between being pushed by a jet of hot gas one unit (in the direction indicated by the next symbol in the jet pattern) and then falling one unit down. If any movement would cause any part of the rock to move into the walls, floor, or a stopped rock, the movement instead does not occur. If a downward movement would have caused a falling rock to move into the floor or an already-fallen rock, the falling rock stops where it is (having landed on something) and a new rock immediately begins falling.

  Drawing falling rocks with @ and stopped rocks with #, the jet pattern in the example above manifests as follows:

  The first rock begins falling:
  |..@@@@.|
  |.......|
  |.......|
  |.......|
  +-------+

  Jet of gas pushes rock right:
  |...@@@@|
  |.......|
  |.......|
  |.......|
  +-------+

  Rock falls 1 unit:
  |...@@@@|
  |.......|
  |.......|
  +-------+

  Jet of gas pushes rock right, but nothing happens:
  |...@@@@|
  |.......|
  |.......|
  +-------+

  Rock falls 1 unit:
  |...@@@@|
  |.......|
  +-------+

  Jet of gas pushes rock right, but nothing happens:
  |...@@@@|
  |.......|
  +-------+

  Rock falls 1 unit:
  |...@@@@|
  +-------+

  Jet of gas pushes rock left:
  |..@@@@.|
  +-------+

  Rock falls 1 unit, causing it to come to rest:
  |..####.|
  +-------+

  A new rock begins falling:
  |...@...|
  |..@@@..|
  |...@...|
  |.......|
  |.......|
  |.......|
  |..####.|
  +-------+

  Jet of gas pushes rock left:
  |..@....|
  |.@@@...|
  |..@....|
  |.......|
  |.......|
  |.......|
  |..####.|
  +-------+

  Rock falls 1 unit:
  |..@....|
  |.@@@...|
  |..@....|
  |.......|
  |.......|
  |..####.|
  +-------+

  Jet of gas pushes rock right:
  |...@...|
  |..@@@..|
  |...@...|
  |.......|
  |.......|
  |..####.|
  +-------+

  Rock falls 1 unit:
  |...@...|
  |..@@@..|
  |...@...|
  |.......|
  |..####.|
  +-------+

  Jet of gas pushes rock left:
  |..@....|
  |.@@@...|
  |..@....|
  |.......|
  |..####.|
  +-------+

  Rock falls 1 unit:
  |..@....|
  |.@@@...|
  |..@....|
  |..####.|
  +-------+

  Jet of gas pushes rock right:
  |...@...|
  |..@@@..|
  |...@...|
  |..####.|
  +-------+

  Rock falls 1 unit, causing it to come to rest:
  |...#...|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  A new rock begins falling:
  |....@..|
  |....@..|
  |..@@@..|
  |.......|
  |.......|
  |.......|
  |...#...|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  The moment each of the next few rocks begins falling, you would see this:

  |..@....|
  |..@....|
  |..@....|
  |..@....|
  |.......|
  |.......|
  |.......|
  |..#....|
  |..#....|
  |####...|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  |..@@...|
  |..@@...|
  |.......|
  |.......|
  |.......|
  |....#..|
  |..#.#..|
  |..#.#..|
  |#####..|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  |..@@@@.|
  |.......|
  |.......|
  |.......|
  |....##.|
  |....##.|
  |....#..|
  |..#.#..|
  |..#.#..|
  |#####..|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  |...@...|
  |..@@@..|
  |...@...|
  |.......|
  |.......|
  |.......|
  |.####..|
  |....##.|
  |....##.|
  |....#..|
  |..#.#..|
  |..#.#..|
  |#####..|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  |....@..|
  |....@..|
  |..@@@..|
  |.......|
  |.......|
  |.......|
  |..#....|
  |.###...|
  |..#....|
  |.####..|
  |....##.|
  |....##.|
  |....#..|
  |..#.#..|
  |..#.#..|
  |#####..|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  |..@....|
  |..@....|
  |..@....|
  |..@....|
  |.......|
  |.......|
  |.......|
  |.....#.|
  |.....#.|
  |..####.|
  |.###...|
  |..#....|
  |.####..|
  |....##.|
  |....##.|
  |....#..|
  |..#.#..|
  |..#.#..|
  |#####..|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  |..@@...|
  |..@@...|
  |.......|
  |.......|
  |.......|
  |....#..|
  |....#..|
  |....##.|
  |....##.|
  |..####.|
  |.###...|
  |..#....|
  |.####..|
  |....##.|
  |....##.|
  |....#..|
  |..#.#..|
  |..#.#..|
  |#####..|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  |..@@@@.|
  |.......|
  |.......|
  |.......|
  |....#..|
  |....#..|
  |....##.|
  |##..##.|
  |######.|
  |.###...|
  |..#....|
  |.####..|
  |....##.|
  |....##.|
  |....#..|
  |..#.#..|
  |..#.#..|
  |#####..|
  |..###..|
  |...#...|
  |..####.|
  +-------+

  To prove to the elephants your simulation is accurate, they want to know how tall the tower will get after 2022 rocks have stopped (but before the 2023rd rock begins falling). In this example, the tower of rocks will be 3068 units tall.

  How many units tall will the tower of rocks be after 2022 rocks have stopped falling?


  ## Example
    iex> part_1(test_input(:part_1))
    3068
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> tetris(2022)
    |> Map.get(:highest)
  end

  @doc ~S"""
  ## Example
    # iex> part_2(test_input(:part_1))
    # 1514285714288
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> tetris(1_000_000_000_000)
    |> Map.get(:highest)
  end

  def tetris(state, 0), do: state

  def tetris(initial_state, shapes_to_play) do
    {shape, state} = get_shape(initial_state)
    initial_offset = {2, 3 + state.highest}

    state
    |> move_shape(shape, initial_offset)
    |> tetris(shapes_to_play - 1)
  end

  def print_tetris(%{state: state, highest: h}) do
    IO.puts("\n")

    state
    |> Map.put_new({0, 0}, "-")
    |> Map.put_new({6, 7}, "-")
    |> Map.put_new({0, h + 5}, "-")
    |> Advent2022.print_grid(dir: :opposite)
  end

  def move_shape(state, shape, offset) do
    move_shape({state, shape, offset})
  end

  def move_shape({initial_state, shape, offset}) do
    {instruction, state} = get_instruction(initial_state)

    case apply_instuctions(state, shape, offset, instruction) do
      {:halt, final_offset} -> commit_shape(state, shape, final_offset)
      {:cont, next_offset} -> move_shape(state, shape, next_offset)
    end
  end

  def commit_shape(state, shape, final_offset) do
    moved_shape = Map.new(shape, fn {loc, val} -> {add(loc, final_offset), val} end)
    highest_block = moved_shape |> Enum.map(fn {{_x, y}, _} -> y end) |> Enum.max()
    highest = max(highest_block + 1, state.highest)

    %{
      state
      | state:
          state.state
          |> Map.merge(moved_shape)
          |> Map.filter(fn {{_x, y}, _} -> y >= max(0, highest - 100) end),
        highest: highest
    }
  end

  def apply_instuctions(state, shape, offset, instruction) do
    offset_1 =
      offset
      |> apply_instuction(instruction)
      |> then(fn o -> if(clear?(state, shape, o), do: o, else: offset) end)

    offset_2 =
      offset_1
      |> apply_instuction("v")
      |> then(fn o -> if(clear?(state, shape, o), do: o, else: offset_1) end)

    if offset_2 == offset_1 do
      {:halt, offset_2}
    else
      {:cont, offset_2}
    end
  end

  def clear?(%{state: state, highest: highest}, shape, offset) do
    shape
    |> Enum.map(fn {loc, "#"} -> add(loc, offset) end)
    |> Enum.all?(fn {x, y} = updated_loc ->
      is_nil(state[updated_loc]) and x in 0..6 and y >= max(0, highest - 100)
    end)
  end

  def add({ax, ay}, {bx, by}), do: {ax + bx, ay + by}

  def apply_instuction({x, y}, "<"), do: {x - 1, y}
  def apply_instuction({x, y}, ">"), do: {x + 1, y}
  def apply_instuction({x, y}, "v"), do: {x, y - 1}

  def get_shape(%{shapes: shapes} = state) do
    {next, updated} = cycle(shapes)
    {next, Map.put(state, :shapes, updated)}
  end

  def get_instruction(%{instructions: instructions} = state) do
    {next, updated} = cycle(instructions)
    {next, Map.put(state, :instructions, updated)}
  end

  def cycle([[], used]), do: cycle([Enum.reverse(used), []])
  def cycle([[next | unused], used]), do: {next, [unused, [next | used]]}

  def parse(stream_input) do
    %{
      shapes: [shapes(), []],
      instructions: [parse_instructions(stream_input), []],
      state: %{},
      highest: 0
    }
  end

  def parse_instructions(stream_input) do
    stream_input
    |> Enum.flat_map(&String.graphemes/1)
  end

  def test_input(:part_1) do
    """
    >>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
    """
  end

  def shapes do
    ["-", "+", "⅃", "|", "■"]
    |> Enum.map(&shape/1)
  end

  def shape("-") do
    """
    ####
    """
    |> parse_shape()
  end

  def shape("+") do
    """
    .#.
    ###
    .#.
    """
    |> parse_shape()
  end

  def shape("⅃") do
    """
    ..#
    ..#
    ###
    """
    |> parse_shape()
  end

  def shape("|") do
    """
    #
    #
    #
    #
    """
    |> parse_shape()
  end

  def shape("■") do
    """
    ##
    ##
    """
    |> parse_shape()
  end

  def parse_shape(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", x}, inner_acc ->
          Map.put(inner_acc, {x, y}, "#")

        _, inner_acc ->
          inner_acc
      end)
    end)
  end
end
