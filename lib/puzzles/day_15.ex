defmodule Day15 do
  import Advent2022

  @doc ~S"""
  --- Day 15: Beacon Exclusion Zone ---
  You feel the ground rumble again as the distress signal leads you to a large network of subterranean tunnels. You don't have time to search them all, but you don't need to: your pack contains a set of deployable sensors that you imagine were originally built to locate lost Elves.

  The sensors aren't very powerful, but that's okay; your handheld device indicates that you're close enough to the source of the distress signal to use them. You pull the emergency sensor system out of your pack, hit the big button on top, and the sensors zoom off down the tunnels.

  Once a sensor finds a spot it thinks will give it a good reading, it attaches itself to a hard surface and begins monitoring for the nearest signal source beacon. Sensors and beacons always exist at integer coordinates. Each sensor knows its own position and can determine the position of a beacon precisely; however, sensors can only lock on to the one beacon closest to the sensor as measured by the Manhattan distance. (There is never a tie where two beacons are the same distance to a sensor.)

  It doesn't take long for the sensors to report back their positions and closest beacons (your puzzle input). For example:

  #{test_input(:part_1)}

  So, consider the sensor at 2,18; the closest beacon to it is at -2,15. For the sensor at 9,16, the closest beacon to it is at 10,16.

  Drawing sensors as S and beacons as B, the above arrangement of sensors and beacons looks like this:

               1    1    2    2
     0    5    0    5    0    5
  0 ....S.......................
  1 ......................S.....
  2 ...............S............
  3 ................SB..........
  4 ............................
  5 ............................
  6 ............................
  7 ..........S.......S.........
  8 ............................
  9 ............................
  10 ....B.......................
  11 ..S.........................
  12 ............................
  13 ............................
  14 ..............S.......S.....
  15 B...........................
  16 ...........SB...............
  17 ................S..........B
  18 ....S.......................
  19 ............................
  20 ............S......S........
  21 ............................
  22 .......................B....

  This isn't necessarily a comprehensive map of all beacons in the area, though. Because each sensor only identifies its closest beacon, if a sensor detects a beacon, you know there are no other beacons that close or closer to that sensor. There could still be beacons that just happen to not be the closest beacon to any sensor. Consider the sensor at 8,7:

               1    1    2    2
     0    5    0    5    0    5
  -2 ..........#.................
  -1 .........###................
  0 ....S...#####...............
  1 .......#######........S.....
  2 ......#########S............
  3 .....###########SB..........
  4 ....#############...........
  5 ...###############..........
  6 ..#################.........
  7 .#########S#######S#........
  8 ..#################.........
  9 ...###############..........
  10 ....B############...........
  11 ..S..###########............
  12 ......#########.............
  13 .......#######..............
  14 ........#####.S.......S.....
  15 B........###................
  16 ..........#SB...............
  17 ................S..........B
  18 ....S.......................
  19 ............................
  20 ............S......S........
  21 ............................
  22 .......................B....

  This sensor's closest beacon is at 2,10, and so you know there are no beacons that close or closer (in any positions marked #).

  None of the detected beacons seem to be producing the distress signal, so you'll need to work out where the distress beacon is by working out where it isn't. For now, keep things simple by counting the positions where a beacon cannot possibly be along just a single row.

  So, suppose you have an arrangement of beacons and sensors like in the example above and, just in the row where y=10, you'd like to count the number of positions a beacon cannot possibly exist. The coverage from all sensors near that row looks like this:

                 1    1    2    2
       0    5    0    5    0    5
  9 ...#########################...
  10 ..####B######################..
  11 .###S#############.###########.

  In this example, in the row where y=10, there are 26 positions where a beacon cannot be present.

  Consult the report from the sensors you just deployed. In the row where y=2000000, how many positions cannot contain a beacon?


  ## Example
    iex> part_1(test_input(:part_1), "10")
    26

    iex> part_1(test_input(:part_1), "9")
    25

    iex> part_1(test_input(:part_1), "11")
    27
  """
  def_solution part_1(stream_input, test_row_string) do
    test_row = String.to_integer(test_row_string)

    stream_input
    |> parse()
    |> count_points_in_row(test_row)
  end

  @doc ~S"""
  --- Part Two ---
  Your handheld device indicates that the distress signal is coming from a beacon nearby. The distress beacon is not detected by any sensor, but the distress beacon must have x and y coordinates each no lower than 0 and no larger than 4000000.

  To isolate the distress beacon's signal, you need to determine its tuning frequency, which can be found by multiplying its x coordinate by 4000000 and then adding its y coordinate.

  In the example above, the search space is smaller: instead, the x and y coordinates can each be at most 20. With this reduced search area, there is only a single position that could have a beacon: x=14, y=11. The tuning frequency for this distress beacon is 56000011.

  Find the only possible position for the distress beacon. What is its tuning frequency?

  ## Example
      iex> part_2(test_input(:part_1), "20")
      56000011
  """
  def_solution part_2(stream_input, size) do
    size = String.to_integer(size)
    polygons = stream_input |> parse() |> Map.get(:polygons)

    polygons
    |> Enum.map(&expand_within_size(&1))
    |> find_intersections(0..size, MapSet.new())
    |> Enum.find(fn intersection ->
      not Enum.any?(polygons, &point_in_polygon(&1, intersection))
    end)
    |> then(fn {x, y} -> x * 4_000_000 + y end)
  end

  defp find_intersections([_tail], _range, acc), do: acc

  defp find_intersections([head | tail], test_range, acc) do
    intersections =
      tail
      |> Enum.flat_map(&get_intersections(&1, head))
      |> Enum.filter(fn
        {x, y} -> x in test_range and y in test_range
        _x -> false
      end)

    find_intersections(tail, test_range, MapSet.union(acc, MapSet.new(intersections)))
  end

  def get_intersections(
        {a1, a2, a3, a4},
        {b1, b2, b3, b4}
      ) do
    [
      get_intersections(a1, a2, b2, b3),
      get_intersections(a1, a2, b4, b1),
      get_intersections(a3, a4, b2, b3),
      get_intersections(a3, a4, b4, b1),
      get_intersections(a2, a3, b1, b2),
      get_intersections(a2, a3, b3, b4),
      get_intersections(a4, a1, b1, b2),
      get_intersections(a4, a1, b1, b3)
    ]
  end

  @doc ~S"""
  ## Example
    iex> get_intersections({-5, -5}, {5, 5}, {-5, 5}, {5, -5})
    {0, 0}
  """
  def get_intersections({ax1, ay1}, {ax2, _ay2}, {bx1, by1}, {_bx2, _by2}) do
    ay_intercept = ay1 - 1 * ax1
    by_intercept = by1 - -1 * bx1

    x = div(by_intercept - ay_intercept, 1 - -1)
    y = 1 * x + ay_intercept

    if x in ax1..ax2 do
      {x, y}
    end
  end

  defp expand_within_size({{x1, y1}, {x2, y2}, {x3, y3}, {x4, y4}}) do
    {{x1 - 1, y1}, {x2, y2 - 1}, {x3 + 1, y3}, {x4, y4 + 1}}
  end

  defp count_points_in_row(state, test_row) do
    Enum.count(state.min_x..state.max_x, fn point ->
      test_point = {point, test_row}

      test_point not in state.beacons and test_point not in state.sensors and
        Enum.any?(state.polygons, &point_in_polygon(&1, test_point))
    end)
  end

  defp point_in_polygon({{x1, y1}, {x2, y2}, {x3, y3}, {x4, y4}}, {xp, yp}) do
    result_1 = (yp - y1) * (x2 - x1) - (xp - x1) * (y2 - y1)
    result_2 = (yp - y2) * (x3 - x2) - (xp - x2) * (y3 - y2)
    result_3 = (yp - y3) * (x4 - x3) - (xp - x3) * (y4 - y3)
    result_4 = (yp - y4) * (x1 - x4) - (xp - x4) * (y1 - y4)

    [result_1, result_2, result_3, result_4]
    |> Enum.map(&compare/1)
    |> Enum.uniq()
    |> then(fn
      [_exactly_one] -> true
      [_exactly, _two] = opts -> :eq in opts
      _three -> false
    end)
  end

  defp compare(0), do: :eq
  defp compare(x) when x < 0, do: :lt
  defp compare(x) when x > 0, do: :gt

  defp parse(stream_input, opts \\ []) do
    Enum.reduce(stream_input, initial_state(), fn line, state ->
      [sensor_x, sensor_y, beacon_x, beacon_y] =
        ~r/Sensor at x=(.+), y=(.+): closest beacon is at x=(.+), y=(.+)/
        |> Regex.run(line)
        |> Enum.drop(1)
        |> Enum.map(&String.to_integer/1)

      beacon = {beacon_x, beacon_y}
      sensor = {sensor_x, sensor_y}
      d = manhattan_distance(sensor, beacon) + Keyword.get(opts, :additional_ploygon_size, 0)

      %{
        max_x: get_max(state.max_x, sensor_x + d),
        min_x: get_min(state.min_x, sensor_x - d),
        max_y: get_max(state.max_y, sensor_y + d),
        min_y: get_min(state.min_y, sensor_y - d),
        beacons: MapSet.put(state.beacons, beacon),
        sensors: MapSet.put(state.sensors, sensor),
        polygons: [
          {{sensor_x - d, sensor_y}, {sensor_x, sensor_y - d}, {sensor_x + d, sensor_y},
           {sensor_x, sensor_y + d}}
          | state.polygons
        ]
      }
    end)
  end

  def manhattan_distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  defp get_max(nil, val), do: val
  defp get_max(a, b), do: max(a, b)

  defp get_min(nil, val), do: val
  defp get_min(a, b), do: min(a, b)

  defp initial_state() do
    %{
      max_x: nil,
      min_x: nil,
      max_y: nil,
      min_y: nil,
      beacons: MapSet.new(),
      sensors: MapSet.new(),
      polygons: []
    }
  end

  def test_input(:part_1) do
    """
    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3
    """
  end
end

