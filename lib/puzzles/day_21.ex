defmodule Day21 do
  import Advent2022

  @doc ~S"""
  --- Day 21: Monkey Math ---
  The monkeys are back! You're worried they're going to try to steal your stuff again, but it seems like they're just holding their ground and making various monkey noises at you.

  Eventually, one of the elephants realizes you don't speak monkey and comes over to interpret. As it turns out, they overheard you talking about trying to find the grove; they can show you a shortcut if you answer their riddle.

  Each monkey is given a job: either to yell a specific number or to yell the result of a math operation. All of the number-yelling monkeys know their number from the start; however, the math operation monkeys need to wait for two other monkeys to yell a number, and those two other monkeys might also be waiting on other monkeys.

  Your job is to work out the number the monkey named root will yell before the monkeys figure it out themselves.

  For example:
  #{test_input(:part_1)}

  Each line contains the name of a monkey, a colon, and then the job of that monkey:


  - A lone number means the monkey's job is simply to yell that number.
  - A job like aaaa + bbbb means the monkey waits for monkeys aaaa and bbbb to yell each of their numbers; the monkey then yells the sum of those two numbers.
  - aaaa - bbbb means the monkey yells aaaa's number minus bbbb's number.
  - Job aaaa * bbbb will yell aaaa's number multiplied by bbbb's number.
  - Job aaaa / bbbb will yell aaaa's number divided by bbbb's number.

  So, in the above example, monkey drzm has to wait for monkeys hmdt and zczc to yell their numbers. Fortunately, both hmdt and zczc have jobs that involve simply yelling a single number, so they do this immediately: 32 and 2. Monkey drzm can then yell its number by finding 32 minus 2: 30.

  Then, monkey sjmn has one of its numbers (30, from monkey drzm), and already has its other number, 5, from dbpl. This allows it to yell its own number by finding 30 multiplied by 5: 150.

  This process continues until root yells a number: 152.

  However, your actual situation involves considerably more monkeys. What number will the monkey named root yell?


  ## Example
    iex> part_1(test_input(:part_1))
    152
  """
  def_solution part_1(stream_input) do
    stream_input
    |> compile()
    |> apply(:root, [])
  end

  @doc ~S"""
  ## Example
    iex> part_2(test_input(:part_1))
    301
  """
  def_solution part_2(stream_input) do
    stream_input
    |> compile(fn
      <<"root: ", rest::binary>> = _line ->
        [left, _, right] = String.split(rest, " ")

        Process.put(:left, String.to_atom(left))
        Process.put(:right, String.to_atom(right))

        "root: #{left} == #{right}"

      <<"humn:", _rest::binary>> = _line ->
        "humn: Process.get(:humn)"

      line ->
        line
    end)
    |> find()
  end

  defp find(module) do
    [low, high] =
      Enum.sort_by([:left, :right], fn side ->
        get_num(module, Process.get(side), 0)
      end)

    find_magnitudal(module, low, high, 10)
  end

  defp find_magnitudal(module, low, high, current) do
    target = get_num(module, Process.get(high), current)

    case get_num(module, Process.get(low), current) do
      ^target -> current
      val when val < target -> find_magnitudal(module, low, high, current * 10)
      val when val > target -> find_binary(module, low, high, div(current, 10), current)
    end
  end

  defp find_binary(module, low_side, high_side, low, high) do
    mid = low + div(high - low, 2)
    target = get_num(module, Process.get(high_side), mid)

    case get_num(module, Process.get(low_side), mid) do
      ^target -> mid
      val when val < target -> find_binary(module, low_side, high_side, mid, high)
      val when val > target -> find_binary(module, low_side, high_side, low, mid)
    end
  end

  defp get_num(module, name, humn) do
    Process.put(:humn, humn)
    apply(module, name, [])
  end

  defp compile(stream_input, mapper \\ &Function.identity/1) do
    Code.compiler_options(ignore_module_conflict: true)

    stream_input
    |> parse(mapper)
    |> Code.compile_string()

    Code.compiler_options(ignore_module_conflict: false)

    Day21.Input
  end

  defp parse(stream_input, mapper) do
    body =
      stream_input
      |> Stream.map(fn line -> mapper.(line) end)
      |> Stream.map(fn <<name::binary-size(4), ": ", rest::binary>> ->
        body =
          case String.split(rest, " ") do
            [left, "/", right] -> "div(#{left}(), #{right}())"
            [left, op, right] -> "#{left}() #{op} #{right}()"
            _ -> rest
          end

        "  def #{name}, do: #{body}"
      end)

    """
    defmodule Day21.Input do
    #{Enum.join(body, "\n")}
    end
    """
  end

  def test_input(:part_1) do
    """
    root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32
    """
  end
end
