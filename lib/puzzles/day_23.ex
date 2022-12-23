defmodule Day23 do
  import Advent2022

  @doc ~S"""
  --- Day 23: Unstable Diffusion ---
  You enter a large crater of gray dirt where the grove is supposed to be. All around you, plants you imagine were expected to be full of fruit are instead withered and broken. A large group of Elves has formed in the middle of the grove.

  "...but this volcano has been dormant for months. Without ash, the fruit can't grow!"

  You look up to see a massive, snow-capped mountain towering above you.

  "It's not like there are other active volcanoes here; we've looked everywhere."

  "But our scanners show active magma flows; clearly it's going somewhere."

  They finally notice you at the edge of the grove, your pack almost overflowing from the random star fruit you've been collecting. Behind you, elephants and monkeys explore the grove, looking concerned. Then, the Elves recognize the ash cloud slowly spreading above your recent detour.

  "Why do you--" "How is--" "Did you just--"

  Before any of them can form a complete question, another Elf speaks up: "Okay, new plan. We have almost enough fruit already, and ash from the plume should spread here eventually. If we quickly plant new seedlings now, we can still make it to the extraction point. Spread out!"

  The Elves each reach into their pack and pull out a tiny plant. The plants rely on important nutrients from the ash, so they can't be planted too close together.

  There isn't enough time to let the Elves figure out where to plant the seedlings themselves; you quickly scan the grove (your puzzle input) and note their positions.

  For example:

  ....#..
  ..###.#
  #...#.#
  .#...##
  #.###..
  ##.#.##
  .#..#..

  The scan shows Elves # and empty ground .; outside your scan, more empty ground extends a long way in every direction. The scan is oriented so that north is up; orthogonal directions are written N (north), S (south), W (west), and E (east), while diagonal directions are written NE, NW, SE, SW.

  The Elves follow a time-consuming process to figure out where they should each go; you can speed up this process considerably. The process consists of some number of rounds during which Elves alternate between considering where to move and actually moving.

  During the first half of each round, each Elf considers the eight positions adjacent to themself. If no other Elves are in one of those eight positions, the Elf does not do anything during this round. Otherwise, the Elf looks in each of four directions in the following order and proposes moving one step in the first valid direction:


  - If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving north one step.
  - If there is no Elf in the S, SE, or SW adjacent positions, the Elf proposes moving south one step.
  - If there is no Elf in the W, NW, or SW adjacent positions, the Elf proposes moving west one step.
  - If there is no Elf in the E, NE, or SE adjacent positions, the Elf proposes moving east one step.

  After each Elf has had a chance to propose a move, the second half of the round can begin. Simultaneously, each Elf moves to their proposed destination tile if they were the only Elf to propose moving to that position. If two or more Elves propose moving to the same position, none of those Elves move.

  Finally, at the end of the round, the first direction the Elves considered is moved to the end of the list of directions. For example, during the second round, the Elves would try proposing a move to the south first, then west, then east, then north. On the third round, the Elves would first consider west, then east, then north, then south.

  As a smaller example, consider just these five Elves:

  .....
  ..##.
  ..#..
  .....
  ..##.
  .....

  The northernmost two Elves and southernmost two Elves all propose moving north, while the middle Elf cannot move north and proposes moving south. The middle Elf proposes the same destination as the southwest Elf, so neither of them move, but the other three do:

  ..##.
  .....
  ..#..
  ...#.
  ..#..
  .....

  Next, the northernmost two Elves and the southernmost Elf all propose moving south. Of the remaining middle two Elves, the west one cannot move south and proposes moving west, while the east one cannot move south or west and proposes moving east. All five Elves succeed in moving to their proposed positions:

  .....
  ..##.
  .#...
  ....#
  .....
  ..#..

  Finally, the southernmost two Elves choose not to move at all. Of the remaining three Elves, the west one proposes moving west, the east one proposes moving east, and the middle one proposes moving north; all three succeed in moving:

  ..#..
  ....#
  #....
  ....#
  .....
  ..#..

  At this point, no Elves need to move, and so the process ends.

  The larger example above proceeds as follows:

  == Initial State ==
  ..............
  ..............
  .......#......
  .....###.#....
  ...#...#.#....
  ....#...##....
  ...#.###......
  ...##.#.##....
  ....#..#......
  ..............
  ..............
  ..............

  == End of Round 1 ==
  ..............
  .......#......
  .....#...#....
  ...#..#.#.....
  .......#..#...
  ....#.#.##....
  ..#..#.#......
  ..#.#.#.##....
  ..............
  ....#..#......
  ..............
  ..............

  == End of Round 2 ==
  ..............
  .......#......
  ....#.....#...
  ...#..#.#.....
  .......#...#..
  ...#..#.#.....
  .#...#.#.#....
  ..............
  ..#.#.#.##....
  ....#..#......
  ..............
  ..............

  == End of Round 3 ==
  ..............
  .......#......
  .....#....#...
  ..#..#...#....
  .......#...#..
  ...#..#.#.....
  .#..#.....#...
  .......##.....
  ..##.#....#...
  ...#..........
  .......#......
  ..............

  == End of Round 4 ==
  ..............
  .......#......
  ......#....#..
  ..#...##......
  ...#.....#.#..
  .........#....
  .#...###..#...
  ..#......#....
  ....##....#...
  ....#.........
  .......#......
  ..............

  == End of Round 5 ==
  .......#......
  ..............
  ..#..#.....#..
  .........#....
  ......##...#..
  .#.#.####.....
  ...........#..
  ....##..#.....
  ..#...........
  ..........#...
  ....#..#......
  ..............

  After a few more rounds...

  == End of Round 10 ==
  .......#......
  ...........#..
  ..#.#..#......
  ......#.......
  ...#.....#..#.
  .#......##....
  .....##.......
  ..#........#..
  ....#.#..#....
  ..............
  ....#..#..#...
  ..............

  To make sure they're on the right track, the Elves like to check after round 10 that they're making good progress toward covering enough ground. To do this, count the number of empty ground tiles contained by the smallest rectangle that contains every Elf. (The edges of the rectangle should be aligned to the N/S/E/W directions; the Elves do not have the patience to calculate arbitrary rectangles.) In the above example, that rectangle is:

  ......#.....
  ..........#.
  .#.#..#.....
  .....#......
  ..#.....#..#
  #......##...
  ....##......
  .#........#.
  ...#.#..#...
  ............
  ...#..#..#..

  In this region, the number of empty ground tiles is 110.

  Simulate the Elves' process and find the smallest rectangle that contains the Elves after 10 rounds. How many empty ground tiles does that rectangle contain?

  ## Example
    iex> part_1(test_input(:part_1))
    110
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> then(fn state ->
      Enum.reduce(0..10, state, fn gen, acc ->
        simulate(acc, gen)
      end)
    end)
    |> count_empty_space()
  end

  @doc ~S"""
  It seems you're on the right track. Finish simulating the process and figure out where the Elves need to go. How many rounds did you save them?

  In the example above, the first round where no Elf moved was round 20:

  .......#......
  ....#......#..
  ..#.....#.....
  ......#.......
  ...#....#.#..#
  #.............
  ....#.....#...
  ..#.....#.....
  ....#.#....#..
  .........#....
  ....#......#..
  .......#......

  Figure out where the Elves need to go. What is the number of the first round where no Elf moves?

  ## Example
    iex> part_2(test_input(:part_1))
    20
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> then(fn state ->
      0
      |> Stream.unfold(fn n -> {n, n + 1} end)
      |> Enum.reduce_while(state, fn gen, acc ->
        case simulate(acc, gen) do
          ^acc -> {:halt, gen + 1}
          next -> {:cont, next}
        end
      end)
    end)
  end

  defp count_empty_space(state) do
    {{_x, max_y}, _} = Enum.max_by(state, fn {{_x, y}, _} -> y end)
    {{max_x, _y}, _} = Enum.max_by(state, fn {{x, _y}, _} -> x end)

    {{_x, min_y}, _} = Enum.min_by(state, fn {{_x, y}, _} -> y end)
    {{min_x, _y}, _} = Enum.min_by(state, fn {{x, _y}, _} -> x end)

    (max_x - min_x + 1) * (max_y - min_y + 1) - map_size(state)
  end

  @doc ~S"""
  ## Example
    iex> expected = test_input(:small_2) |> Advent2022.stream() |> parse()
    iex> expected == test_input(:small_1) |> Advent2022.stream() |> parse() |> simulate(0)
    true

    iex> expected = test_input(:small_3) |> Advent2022.stream() |> parse()
    iex> expected == test_input(:small_2) |> Advent2022.stream() |> parse() |> simulate(1)
    true

    iex> expected = test_input(:small_4) |> Advent2022.stream() |> parse()
    iex> expected == test_input(:small_3) |> Advent2022.stream() |> parse() |> simulate(2)
    true
  """
  def simulate(state, generation) do
    state
    |> Enum.map(fn {cord, "#"} ->
      {propose_move(cord, generation, state), cord}
    end)
    |> Enum.group_by(fn {key, _} -> key end, fn {_, val} -> val end)
    |> Enum.flat_map(fn
      {key, [_single_value]} -> [{key, "#"}]
      {_key, multiple_values} -> Enum.map(multiple_values, fn val -> {val, "#"} end)
    end)
    |> Map.new()
  end

  defp propose_move(cord, generation, state) do
    neighbors = get_neighbors(cord, state)

    cond do
      Enum.all?(neighbors, &is_nil/1) -> cord
      proposition = check_sides(cord, generation, neighbors) -> proposition
      :other -> cord
    end
  end

  defp check_sides(cord, generation, neighbors) do
    generation..(generation + 3)
    |> Enum.map(&rem(&1, 4))
    |> Enum.find_value(&check_side(&1, cord, neighbors))
  end

  # north
  defp check_side(0, {x, y}, neighbors) do
    case neighbors do
      [nil = _nw, nil = _n, nil = _ne, _e, _se, _s, _sw, _w] -> {x, y - 1}
      _ -> nil
    end
  end

  # south
  defp check_side(1, {x, y}, neighbors) do
    case neighbors do
      [_nw, _n, _ne, _w, _e, nil = _sw, nil = _s, nil = _se] -> {x, y + 1}
      _ -> nil
    end
  end

  # west
  defp check_side(2, {x, y}, neighbors) do
    case neighbors do
      [nil = _nw, _n, _ne, nil = _w, _e, nil = _sw, _s, _se] -> {x - 1, y}
      _ -> nil
    end
  end

  # east
  defp check_side(3, {x, y}, neighbors) do
    case neighbors do
      [_nw, _n, nil = _ne, _w, nil = _e, _sw, _s, nil = _se] -> {x + 1, y}
      _ -> nil
    end
  end

  # [nw, n, ne, w, e, sw, s, se]
  defp get_neighbors({x, y}, state) do
    for yy <- (y - 1)..(y + 1), xx <- (x - 1)..(x + 1), {x, y} != {xx, yy} do
      Map.get(state, {xx, yy})
    end
  end

  def parse(stream_input) do
    for {line, y} <- Enum.with_index(stream_input),
        {cell, x} <- line |> String.graphemes() |> Enum.with_index(),
        cell == "#",
        into: %{} do
      {{x, y}, "#"}
    end
  end

  def test_input(:part_1) do
    """
    ..............
    ..............
    .......#......
    .....###.#....
    ...#...#.#....
    ....#...##....
    ...#.###......
    ...##.#.##....
    ....#..#......
    ..............
    ..............
    ..............
    """
  end

  def test_input(:small_1) do
    """
    .....
    ..##.
    ..#..
    .....
    ..##.
    .....
    """
  end

  def test_input(:small_2) do
    """
    ..##.
    .....
    ..#..
    ...#.
    ..#..
    .....
    """
  end

  def test_input(:small_3) do
    """
    .....
    ..##.
    .#...
    ....#
    .....
    ..#..
    """
  end

  def test_input(:small_4) do
    """
    ..#..
    ....#
    #....
    ....#
    .....
    ..#..
    """
  end
end

