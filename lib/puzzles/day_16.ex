defmodule Day16 do
  import Advent2022

  @doc ~S"""
  --- Day 16: Proboscidea Volcanium ---
  The sensors have led you to the origin of the distress signal: yet another handheld device, just like the one the Elves gave you. However, you don't see any Elves around; instead, the device is surrounded by elephants! They must have gotten lost in these tunnels, and one of the elephants apparently figured out how to turn on the distress signal.

  The ground rumbles again, much stronger this time. What kind of cave is this, exactly? You scan the cave with your handheld device; it reports mostly igneous rock, some ash, pockets of pressurized gas, magma... this isn't just a cave, it's a volcano!

  You need to get the elephants out of here, quickly. Your device estimates that you have 30 minutes before the volcano erupts, so you don't have time to go back out the way you came in.

  You scan the cave for other options and discover a network of pipes and pressure-release valves. You aren't sure how such a system got into a volcano, but you don't have time to complain; your device produces a report (your puzzle input) of each valve's flow rate if it were opened (in pressure per minute) and the tunnels you could use to move between the valves.

  There's even a valve in the room you and the elephants are currently standing in labeled AA. You estimate it will take you one minute to open a single valve and one minute to follow any tunnel from one valve to another. What is the most pressure you could release?

  For example, suppose you had the following scan output:

  #{test_input(:part_1)}

  All of the valves begin closed. You start at valve AA, but it must be damaged or jammed or something: its flow rate is 0, so there's no point in opening it. However, you could spend one minute moving to valve BB and another minute opening it; doing so would release pressure during the remaining 28 minutes at a flow rate of 13, a total eventual pressure release of 28 * 13 = 364. Then, you could spend your third minute moving to valve CC and your fourth minute opening it, providing an additional 26 minutes of eventual pressure release at a flow rate of 2, or 52 total pressure released by valve CC.

  Making your way through the tunnels like this, you could probably open many or all of the valves by the time 30 minutes have elapsed. However, you need to release as much pressure as possible, so you'll need to be methodical. Instead, consider this approach:

  == Minute 1 ==
  No valves are open.
  You move to valve DD.

  == Minute 2 ==
  No valves are open.
  You open valve DD.

  == Minute 3 ==
  Valve DD is open, releasing 20 pressure.
  You move to valve CC.

  == Minute 4 ==
  Valve DD is open, releasing 20 pressure.
  You move to valve BB.

  == Minute 5 ==
  Valve DD is open, releasing 20 pressure.
  You open valve BB.

  == Minute 6 ==
  Valves BB and DD are open, releasing 33 pressure.
  You move to valve AA.

  == Minute 7 ==
  Valves BB and DD are open, releasing 33 pressure.
  You move to valve II.

  == Minute 8 ==
  Valves BB and DD are open, releasing 33 pressure.
  You move to valve JJ.

  == Minute 9 ==
  Valves BB and DD are open, releasing 33 pressure.
  You open valve JJ.

  == Minute 10 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You move to valve II.

  == Minute 11 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You move to valve AA.

  == Minute 12 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You move to valve DD.

  == Minute 13 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You move to valve EE.

  == Minute 14 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You move to valve FF.

  == Minute 15 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You move to valve GG.

  == Minute 16 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You move to valve HH.

  == Minute 17 ==
  Valves BB, DD, and JJ are open, releasing 54 pressure.
  You open valve HH.

  == Minute 18 ==
  Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
  You move to valve GG.

  == Minute 19 ==
  Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
  You move to valve FF.

  == Minute 20 ==
  Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
  You move to valve EE.

  == Minute 21 ==
  Valves BB, DD, HH, and JJ are open, releasing 76 pressure.
  You open valve EE.

  == Minute 22 ==
  Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
  You move to valve DD.

  == Minute 23 ==
  Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
  You move to valve CC.

  == Minute 24 ==
  Valves BB, DD, EE, HH, and JJ are open, releasing 79 pressure.
  You open valve CC.

  == Minute 25 ==
  Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

  == Minute 26 ==
  Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

  == Minute 27 ==
  Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

  == Minute 28 ==
  Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

  == Minute 29 ==
  Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

  == Minute 30 ==
  Valves BB, CC, DD, EE, HH, and JJ are open, releasing 81 pressure.

  This approach lets you release the most pressure possible in 30 minutes with this valve layout, 1651.

  Work out the steps to release the most pressure in 30 minutes. What is the most pressure you can release?


  ## Example
    iex> part_1(test_input(:part_1))
    1651
  """
  def_solution part_1(stream_input) do
    graph = stream_input |> build_graph()

    [state("AA")]
    |> simulate(graph, 30)
    |> Enum.max_by(& &1.released_pressure)
    |> Map.get(:released_pressure)
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
  """
  def_solution part_2(stream_input) do
    stream_input
  end

  defp simulate(points, _graph, 0), do: points

  defp simulate(points, graph, remaining_minutes) do
    points
    |> Enum.flat_map(&do_simulate(&1, graph))
    |> Enum.uniq_by(fn state ->
      {state.current_location, state.released_pressure, state.on_valves}
    end)
    |> Enum.sort_by(& &1.released_pressure, :desc)
    |> Enum.take(1000)
    |> simulate(graph, remaining_minutes - 1)
  end

  defp do_simulate(%{current_location: current_location} = og_point, graph) do
    point = update_pressue(og_point)

    {^current_location, pressure} = :digraph.vertex(graph, current_location)
    neighbors = :digraph.out_neighbours(graph, current_location)

    moves =
      neighbors
      |> Enum.reject(fn neighbor ->
        point.previous_states[neighbor] == point.on_valves
      end)
      |> Enum.map(fn neighbor ->
        %{
          point
          | current_location: neighbor,
            previous_states: Map.put(point.previous_states, neighbor, point.on_valves)
        }
      end)

    if pressure > 0 and not Map.has_key?(point.on_valves, current_location) do
      new_on_valves = Map.put(point.on_valves, current_location, pressure)

      [
        %{
          point
          | on_valves: new_on_valves,
            previous_states: Map.put(point.previous_states, current_location, pressure)
        }
        | moves
      ]
    else
      moves
    end
  end

  defp update_pressue(%{on_valves: on_valves} = point) do
    pressure = on_valves |> Map.values() |> Enum.sum()
    Map.update!(point, :released_pressure, &(&1 + pressure))
  end

  defp state(starting_valve) do
    %{
      current_location: starting_valve,
      previous_states: %{},
      released_pressure: 0,
      on_valves: %{}
    }
  end

  # increment pressure
  # if valve is off, it can be turned on, record it being on
  # if valve is off and its pressure is 0 move to neighbor
  # if valve is on, move to a neighbor

  defp build_graph(stream_input) do
    graph = :digraph.new()

    stream_input
    |> Stream.each(fn line ->
      [[_, valve, rate, rest]] =
        Regex.scan(~r/Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? (.+)/, line)

      :digraph.add_vertex(graph, valve, String.to_integer(rate))

      rest
      |> String.split(", ")
      |> Enum.each(fn leads_to ->
        unless :digraph.vertex(graph, leads_to) do
          :digraph.add_vertex(graph, leads_to)
        end

        :digraph.add_edge(graph, valve, leads_to)
      end)
    end)
    |> Stream.run()

    graph
  end

  def test_input(:part_1) do
    """
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
    """
  end
end
