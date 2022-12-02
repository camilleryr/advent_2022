defmodule Day2 do
  import Advent2022

  @selections %{
    rock: %{beats: :scisors, looses_to: :paper},
    paper: %{beats: :rock, looses_to: :scisors},
    scisors: %{beats: :paper, looses_to: :rock}
  }

  @doc ~S"""
  --- Day 2: Rock Paper Scissors ---
  The Elves begin to set up camp on the beach. To decide whose tent gets to be closest to the snack storage, a giant Rock Paper Scissors tournament is already in progress.

  Rock Paper Scissors is a game between two players. Each game contains many rounds; in each round, the players each simultaneously choose one of Rock, Paper, or Scissors using a hand shape. Then, a winner for that round is selected: Rock defeats Scissors, Scissors defeats Paper, and Paper defeats Rock. If both players choose the same shape, the round instead ends in a draw.

  Appreciative of your help yesterday, one Elf gives you an encrypted strategy guide (your puzzle input) that they say will be sure to help you win. "The first column is what your opponent is going to play: A for Rock, B for Paper, and C for Scissors. The second column--" Suddenly, the Elf is called away to help with someone's tent.

  The second column, you reason, must be what you should play in response: X for Rock, Y for Paper, and Z for Scissors. Winning every time would be suspicious, so the responses must have been carefully chosen.

  The winner of the whole tournament is the player with the highest score. Your total score is the sum of your scores for each round. The score for a single round is the score for the shape you selected (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the outcome of the round (0 if you lost, 3 if the round was a draw, and 6 if you won).

  Since you can't be sure if the Elf is trying to help you or trick you, you should calculate the score you would get if you were to follow the strategy guide.

  For example, suppose you were given the following strategy guide:

  This strategy guide predicts and recommends the following:

    #{test_input(:part_1)}

  - In the first round, your opponent will choose Rock (A), and you should choose Paper (Y). This ends in a win for you with a score of 8 (2 because you chose Paper + 6 because you won).
  - In the second round, your opponent will choose Paper (B), and you should choose Rock (X). This ends in a loss for you with a score of 1 (1 + 0).
  - The third round is a draw with both players choosing Scissors, giving you a score of 3 + 3 = 6.

  In this example, if you were to follow the strategy guide, you would get a total score of 15 (8 + 1 + 6).

  What would your total score be if everything goes exactly according to your strategy guide?

  ## Example
    iex> part_1(test_input(:part_1))
    15
  """
  def_solution part_1(stream_input) do
    stream_input
    |> Stream.map(&parse_part_1/1)
    |> Stream.map(&score/1)
    |> Enum.sum()
  end

  @doc """
  --- Part Two ---
  The Elf finishes helping with the tent and sneaks back over to you. "Anyway, the second column says how the round needs to end: X means you need to lose, Y means you need to end the round in a draw, and Z means you need to win. Good luck!"

  The total score is still calculated in the same way, but now you need to figure out what shape to choose so the round ends as indicated. The example above now goes like this:

  In the first round, your opponent will choose Rock (A), and you need the round to end in a draw (Y), so you also choose Rock. This gives you a score of 1 + 3 = 4.
  In the second round, your opponent will choose Paper (B), and you choose Rock so you lose (X) with a score of 1 + 0 = 1.
  In the third round, you will defeat your opponent's Scissors with Rock for a score of 1 + 6 = 7.
  Now that you're correctly decrypting the ultra top secret strategy guide, you would get a total score of 12.

  Following the Elf's instructions for the second column, what would your total score be if everything goes exactly according to your strategy guide?

  ## Example
    iex> part_2(test_input(:part_1))
    12
  """
  def_solution part_2(stream_input) do
    stream_input
    |> Stream.map(&parse_part_2/1)
    |> Stream.map(&score/1)
    |> Enum.sum()
  end

  defp score({a, b}) do
    score_selection(b) + score_result(b, a)
  end

  defp score_selection(:rock), do: 1
  defp score_selection(:paper), do: 2
  defp score_selection(:scisors), do: 3

  defp score_result(same, same), do: 3
  defp score_result(a, b), do: if(@selections[a].beats == b, do: 6, else: 0)

  defp parse_part_1(<<a::binary-size(1), " ", b::binary-size(1)>>) do
    {parse_selection(a), parse_selection(b)}
  end

  defp parse_part_2(<<a::binary-size(1), " ", b::binary-size(1)>>) do
    a = parse_selection(a)
    {a, parse_selection(b, a)}
  end

  defp parse_selection(x) when x in ["A", "X"], do: :rock
  defp parse_selection(x) when x in ["B", "Y"], do: :paper
  defp parse_selection(x) when x in ["C", "Z"], do: :scisors

  defp parse_selection("X", s), do: @selections[s].beats
  defp parse_selection("Y", s), do: s
  defp parse_selection("Z", s), do: @selections[s].looses_to

  def test_input(:part_1) do
    """
    A Y
    B X
    C Z
    """
  end
end

