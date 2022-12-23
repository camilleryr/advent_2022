defmodule Day22 do
  import Advent2022

  @doc ~S"""
  --- Day 22: Monkey Map ---
  The monkeys take you on a surprisingly easy trail through the jungle. They're even going in roughly the right direction according to your handheld device's Grove Positioning System.

  As you walk, the monkeys explain that the grove is protected by a force field. To pass through the force field, you have to enter a password; doing so involves tracing a specific path on a strangely-shaped board.

  At least, you're pretty sure that's what you have to do; the elephants aren't exactly fluent in monkey.

  The monkeys give you notes that they took when they last saw the password entered (your puzzle input).

  For example:
  #{test_input(:part_1)}

  The first half of the monkeys' notes is a map of the board. It is comprised of a set of open tiles (on which you can move, drawn .) and solid walls (tiles which you cannot enter, drawn #).

  The second half is a description of the path you must follow. It consists of alternating numbers and letters:

  - A number indicates the number of tiles to move in the direction you are facing. If you run into a wall, you stop moving forward and continue with the next instruction.
  - A letter indicates whether to turn 90 degrees clockwise (R) or counterclockwise (L). Turning happens in-place; it does not change your current tile.

  So, a path like 10R5 means "go forward 10 tiles, then turn clockwise 90 degrees, then go forward 5 tiles".

  You begin the path in the leftmost open tile of the top row of tiles. Initially, you are facing to the right (from the perspective of how the map is drawn).

  If a movement instruction would take you off of the map, you wrap around to the other side of the board. In other words, if your next tile is off of the board, you should instead look in the direction opposite of your current facing as far as you can until you find the opposite edge of the board, then reappear there.

  For example, if you are at A and facing to the right, the tile in front of you is marked B; if you are at C and facing down, the tile in front of you is marked D:

        ...#
        .#..
        #...
        ....
  ...#.D.....#
  ........#...
  B.#....#...A
  .....C....#.
        ...#....
        .....#..
        .#......
        ......#.

  It is possible for the next tile (after wrapping around) to be a wall; this still counts as there being a wall in front of you, and so movement stops before you actually wrap to the other side of the board.

  By drawing the last facing you had with an arrow on each tile you visit, the full path taken by the above example looks like this:

          >>v#
          .#v.
          #.v.
          ..v.
  ...#...v..v#
  >>>v...>#.>>
  ..#v...#....
  ...>>>>v..#.
          ...#....
          .....#..
          .#......
          ......#.

  To finish providing the password to this strange input device, you need to determine numbers for your final row, column, and facing as your final position appears from the perspective of the original map. Rows start from 1 at the top and count downward; columns start from 1 at the left and count rightward. (In the above example, row 1, column 1 refers to the empty space with no tile on it in the top-left corner.) Facing is 0 for right (&gt;), 1 for down (v), 2 for left (&lt;), and 3 for up (^). The final password is the sum of 1000 times the row, 4 times the column, and the facing.

  In the above example, the final row is 6, the final column is 8, and the final facing is 0. So, the final password is 1000 * 6 + 4 * 8 + 0: 6032.

  Follow the path given in the monkeys' notes. What is the final password?


  ## Example
    iex> part_1(test_input(:part_1))
    6032
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> run_instructions()
    # |> tap(&print_state/1)
    |> score()
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
  """
  def_solution part_2(stream_input) do
    stream_input
  end

  defp score(%{location: {x, y}, direction: dir}) do
    1000 * y + 4 * x + dir
  end

  def print_state(state) do
    IO.puts("\n\n")
    IO.puts("\n\n")

    Map.merge(state.map, state.path)
    |> Advent2022.print_grid(
      transformer: fn
        nil -> " "
        3 -> "A"
        0 -> ">"
        1 -> "V"
        2 -> "<"
        other -> other
      end
    )

    IO.puts("\n\n")
  end

  defp run_instructions(%{instructions: []} = state), do: state

  defp run_instructions(%{instructions: [dir | rest_inst]} = state) when dir in ~w|L R| do
    state
    |> turn(dir)
    |> Map.put(:instructions, rest_inst)
    |> run_instructions()
  end

  defp run_instructions(%{instructions: [steps | rest_inst]} = state) do
    state
    |> move(steps)
    |> Map.put(:instructions, rest_inst)
    |> run_instructions()
  end

  @doc ~S"""
  ## Example
    iex> state = test_input(:part_1) |> String.split("\n", trim: true) |> parse()
    iex> %{state | direction: 0} |> turn("L") |> Map.get(:direction)
    3
    iex> %{state | direction: 0} |> turn("R") |> Map.get(:direction)
    1
    iex> %{state | direction: 3} |> turn("L") |> Map.get(:direction)
    2
    iex> %{state | direction: 3} |> turn("R") |> Map.get(:direction)
    0
  """
  def turn(state, "L"), do: turn(state, -1)
  def turn(state, "R"), do: turn(state, 1)

  def turn(state, int_dir) do
    case state.direction + int_dir do
      dir when dir < 0 -> Map.put(state, :direction, 4 + dir)
      dir when dir >= 0 -> Map.put(state, :direction, rem(dir, 4))
    end
    |> then(fn updated ->
      Map.update!(updated, :path, &Map.put(&1, updated.location, updated.direction))
    end)
  end

  defp move(state, 0), do: state

  defp move(state, steps) do
    next = next(state)

    case Map.get(state.map, next) do
      "#" ->
        state

      "." ->
        move(
          %{state | path: Map.put(state.path, next, state.direction), location: next},
          steps - 1
        )

      nil ->
        IO.inspect(state, label: inspect(next))
        throw(:error)
    end
  end

  @doc ~S"""
  ## Example
    iex> state = test_input(:part_1) |> String.split("\n", trim: true) |> parse()
    iex> next(%{state | location: {12, 6}, direction: 0})
    {1, 6}
    iex> next(%{state | location: {1, 6}, direction: 2})
    {12, 6}
    iex> next(%{state | location: {8, 8}, direction: 1})
    {8, 5}
    iex> next(%{state | location: {8, 5}, direction: 3})
    {8, 8}
  """
  def next(state) do
    case {state.direction, state.location} do
      {3, {x, y}} -> next(state, {x, y - 1})
      {0, {x, y}} -> next(state, {x + 1, y})
      {1, {x, y}} -> next(state, {x, y + 1})
      {2, {x, y}} -> next(state, {x - 1, y})
    end
  end

  def next(%{map: map}, point) when is_map_key(map, point), do: point

  def next(%{max: {max_x, max_y}} = state, {x, y}) do
    case state.direction do
      3 ->
        {x, Enum.find(max_y..1, fn yy -> Map.has_key?(state.map, {x, yy}) end)}

      0 ->
        {Enum.find(1..max_x, fn xx -> Map.has_key?(state.map, {xx, y}) end), y}

      1 ->
        {x, Enum.find(1..max_y, fn yy -> Map.has_key?(state.map, {x, yy}) end)}

      2 ->
        {Enum.find(max_x..1, fn xx -> Map.has_key?(state.map, {xx, y}) end), y}
    end
  end

  @doc false
  def parse(stream_input) do
    {map, max, inst_string} = parse_map(stream_input)
    initial_location = get_initial_location(map)

    %{
      map: map,
      instructions: parse_instructions(inst_string),
      location: initial_location,
      path: %{initial_location => 0},
      direction: 0,
      max: max
    }
  end

  defp parse_instructions(inst_string) do
    ~r/[LR]/
    |> Regex.split(inst_string, include_captures: true)
    |> Enum.map(fn
      dir when dir in ~w|L R| -> dir
      int_string -> String.to_integer(int_string)
    end)
  end

  defp get_initial_location(map) do
    1
    |> Stream.unfold(fn n -> {{n, 1}, n + 1} end)
    |> Enum.find(&Map.get(map, &1))
  end

  defp parse_map(stream_input) do
    {map_input, [inst_input]} = Enum.split(stream_input, -1)

    map =
      for {line, y} <- map_input |> Enum.with_index(1),
          {cell, x} <- line |> String.graphemes() |> Enum.with_index(1),
          cell in ~w|. #|,
          into: %{} do
        {{x, y}, cell}
      end

    {map, {String.length(List.first(map_input)), length(map_input)}, inst_input}
  end

  def test_input(:part_1) do
    """
            ...#
            .#..
            #...
            ....
    ...#.......#
    ........#...
    ..#....#....
    ..........#.
            ...#....
            .....#..
            .#......
            ......#.

    10R5L5R10L4R5L5
    """
  end
end
