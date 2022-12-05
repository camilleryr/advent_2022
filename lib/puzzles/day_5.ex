defmodule Day5 do
  import Advent2022

  @doc ~S"""
  --- Day 5: Supply Stacks ---
  The expedition can depart as soon as the final supplies have been unloaded from the ships. Supplies are stored in stacks of marked crates, but because the needed supplies are buried under many other crates, the crates need to be rearranged.

  The ship has a giant cargo crane capable of moving crates between stacks. To ensure none of the crates get crushed or fall over, the crane operator will rearrange them in a series of carefully-planned steps. After the crates are rearranged, the desired crates will be at the top of each stack.

  The Elves don't want to interrupt the crane operator during this delicate procedure, but they forgot to ask her which crate will end up where, and they want to be ready to unload them as soon as possible so they can embark.

  They do, however, have a drawing of the starting stacks of crates and the rearrangement procedure (your puzzle input). For example:

  #{test_input(:part_1)}

  In this example, there are three stacks of crates. Stack 1 contains two crates: crate Z is on the bottom, and crate N is on top. Stack 2 contains three crates; from bottom to top, they are crates M, C, and D. Finally, stack 3 contains a single crate, P.

  Then, the rearrangement procedure is given. In each step of the procedure, a quantity of crates is moved from one stack to a different stack. In the first step of the above rearrangement procedure, one crate is moved from stack 2 to stack 1, resulting in this configuration:

  [D]
  [N] [C]
  [Z] [M] [P]
   1   2   3

  In the second step, three crates are moved from stack 1 to stack 3. Crates are moved one at a time, so the first crate to be moved (D) ends up below the second and third crates:

         [Z]
         [N]
     [C] [D]
     [M] [P]
  1   2   3

  Then, both crates are moved from stack 2 to stack 1. Again, because crates are moved one at a time, crate C ends up below crate M:

          [Z]
          [N]
  [M]     [D]
  [C]     [P]
   1   2   3

  Finally, one crate is moved from stack 1 to stack 2:

          [Z]
          [N]
          [D]
  [C] [M] [P]
   1   2   3

  The Elves just need to know which crate will end up on top of each stack; in this example, the top crates are C in stack 1, M in stack 2, and Z in stack 3, so you should combine these together and give the Elves the message CMZ.

  After the rearrangement procedure completes, what crate ends up on top of each stack?

  ## Example
    iex> part_1(test_input(:part_1))
    "CMZ"
  """
  def_solution [preserve_newlines: true], part_1(stream_input) do
    {initial_state, instructions} = parse(stream_input)

    instructions
    |> Enum.reduce(initial_state, &apply_instructions(&2, &1))
    |> get_solution()
  end

  @doc """
  --- Part Two ---
  As you watch the crane operator expertly rearrange the crates, you notice the process isn't following your prediction.

  Some mud was covering the writing on the side of the crane, and you quickly wipe it away. The crane isn't a CrateMover 9000 - it's a CrateMover 9001.

  The CrateMover 9001 is notable for many new and exciting features: air conditioning, leather seats, an extra cup holder, and the ability to pick up and move multiple crates at once.

  Again considering the example above, the crates begin in the same configuration:

      [D]
  [N] [C]
  [Z] [M] [P]
  1   2   3
  Moving a single crate from stack 2 to stack 1 behaves the same as before:

  [D]
  [N] [C]
  [Z] [M] [P]
  1   2   3
  However, the action of moving three crates from stack 1 to stack 3 means that those three moved crates stay in the same order, resulting in this new configuration:

          [D]
          [N]
      [C] [Z]
      [M] [P]
  1   2   3
  Next, as both crates are moved from stack 2 to stack 1, they retain their order as well:

          [D]
          [N]
  [C]     [Z]
  [M]     [P]
  1   2   3
  Finally, a single crate is still moved from stack 1 to stack 2, but now it's crate C that gets moved:

          [D]
          [N]
          [Z]
  [M] [C] [P]
  1   2   3
  In this example, the CrateMover 9001 has put the crates in a totally different order: MCD.

  Before the rearrangement process finishes, update your simulation so that the Elves know where they should stand to be ready to unload the final supplies. After the rearrangement procedure completes, what crate ends up on top of each stack?

  ## Example
    iex> part_2(test_input(:part_1))
    "MCD"
  """
  def_solution [preserve_newlines: true], part_2(stream_input) do
    {initial_state, instructions} = parse(stream_input)

    instructions
    |> Enum.reduce(initial_state, &apply_instructions_2(&2, &1))
    |> get_solution()
  end

  defp get_solution(state) do
    Enum.map_join(1..map_size(state), fn idx ->
      List.first(state[idx])
    end)
  end

  defp apply_instructions(state, instruction) do
    if instruction.move == 0 do
      state
    else
      [hd | tail] = state[instruction.from]

      state
      |> Map.put(instruction.from, tail)
      |> Map.update!(instruction.to, &[hd | &1])
      |> apply_instructions(%{instruction | move: instruction.move - 1})
    end
  end

  defp apply_instructions_2(state, instruction) do
    {to, from} = Enum.split(state[instruction.from], instruction.move)

      state
      |> Map.put(instruction.from, from)
      |> Map.update!(instruction.to, &Enum.concat(to, &1))
  end

  defp parse(stream_input) do
    {left, right} = Enum.split_while(stream_input, & &1)
    {parse_initial_state(left), parse_instructions(right)}
  end

  defp parse_instructions(stream_input) do
    stream_input
    |> Stream.drop(1)
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> then(fn ["move", move, "from", from, "to", to] ->
        %{move: String.to_integer(move), from: String.to_integer(from), to: String.to_integer(to)}
      end)
    end)
  end

  defp parse_initial_state(stream_input) do
    stream_input
    |> Enum.reverse()
    |> Enum.drop(1)
    |> Enum.map(fn line ->
      line
      |> String.codepoints()
      |> Enum.drop(1)
      |> Enum.take_every(4)
    end)
    |> Enum.reduce(%{}, fn line, acc ->
      line
      |> Enum.with_index(1)
      |> Enum.reject(fn
        {" ", _idx} -> true
        _ -> false
      end)
      |> Map.new(fn {val, key} -> {key, [val]} end)
      |> then(&Map.merge(acc, &1, fn _key, acc_val, new_val -> new_val ++ acc_val end))
    end)
  end

  def test_input(:part_1) do
    """
        [D]
    [N] [C]
    [Z] [M] [P]
     1   2   3

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
  end
end

