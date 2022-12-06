defmodule Day6 do
  import Advent2022

  @doc ~S"""
  --- Day 6: Tuning Trouble ---
  The preparations are finally complete; you and the Elves leave camp on foot and begin to make your way toward the star fruit grove.

  As you move through the dense undergrowth, one of the Elves gives you a handheld device. He says that it has many fancy features, but the most important one to set up right now is the communication system.

  However, because he's heard you have significant experience dealing with signal-based systems, he convinced the other Elves that it would be okay to give you their one malfunctioning device - surely you'll have no problem fixing it.

  As if inspired by comedic timing, the device emits a few colorful sparks.

  To be able to communicate with the Elves, the device needs to lock on to their signal. The signal is a series of seemingly-random characters that the device receives one at a time.

  To fix the communication system, you need to add a subroutine to the device that detects a start-of-packet marker in the datastream. In the protocol being used by the Elves, the start of a packet is indicated by a sequence of four characters that are all different.

  The device will send your subroutine a datastream buffer (your puzzle input); your subroutine needs to identify the first position where the four most recently received characters were all different. Specifically, it needs to report the number of characters from the beginning of the buffer to the end of the first such four-character marker.

  For example, suppose you receive the following datastream buffer:

  #{test_input(1)}

  After the first three characters (mjq) have been received, there haven't been enough characters received yet to find the marker. The first time a marker could occur is after the fourth character is received, making the most recent four characters mjqj. Because j is repeated, this isn't a marker.

  The first time a marker appears is after the seventh character arrives. Once it does, the last four characters received are jpqm, which are all different. In this case, your subroutine should report the value 7, because the first start-of-packet marker is complete after 7 characters have been processed.

  Here are a few more examples:


  - #{test_input(2)}: first marker after character 5
  - #{test_input(3)}: first marker after character 6
  - #{test_input(4)}: first marker after character 10
  - #{test_input(5)}: first marker after character 11

  How many characters need to be processed before the first start-of-packet marker is detected?

  ## Example
    iex> part_1(test_input(1))
    7

    iex> part_1(test_input(2))
    5

    iex> part_1(test_input(3))
    6

    iex> part_1(test_input(4))
    10

    iex> part_1(test_input(5))
    11
  """
  def_solution part_1(stream_input) do
    stream_input
    |> parse()
    |> find(4)
  end

  @doc ~S"""
  --- Part Two ---
  Your device's communication system is correctly detecting packets, but still isn't working. It looks like it also needs to look for messages.

  A start-of-message marker is just like a start-of-packet marker, except it consists of 14 distinct characters rather than 4.

  Here are the first positions of start-of-message markers for all of the above examples:

    #{test_input(1)}: first marker after character 19
    #{test_input(2)}: first marker after character 23
    #{test_input(3)}: first marker after character 23
    #{test_input(4)}: first marker after character 29
    #{test_input(5)}: first marker after character 26

  How many characters need to be processed before the first start-of-message marker is detected?

  ## Example
    iex> part_2(test_input(1))
    19

    iex> part_2(test_input(2))
    23

    iex> part_2(test_input(3))
    23

    iex> part_2(test_input(4))
    29

    iex> part_2(test_input(5))
    26
  """
  def_solution part_2(stream_input) do
    stream_input
    |> parse()
    |> find(14)
  end

  defp parse(stream_input) do
    Enum.flat_map(stream_input, &String.graphemes/1)
  end

  defp find(sequence, length), do: find(sequence, length, length)

  defp find([_ | rest] = sequence, length, index) do
    if unique(sequence, %{}, length) do
      index
    else
      find(rest, length, index + 1)
    end
  end

  defp unique(_, _, 0), do: true
  defp unique([h | _t], acc, _) when is_map_key(acc, h), do: false
  defp unique([h | t], acc, length), do: unique(t, Map.put(acc, h, :_), length - 1)

  def test_input(1), do: "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
  def test_input(2), do: "bvwbjplbgvbhsrlpgdmjqwftvncz"
  def test_input(3), do: "nppdvjthqldpwncqszvftbrmjlhg"
  def test_input(4), do: "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"
  def test_input(5), do: "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
end

