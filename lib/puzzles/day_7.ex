defmodule Day7 do
  import Advent2022

  @doc ~S"""
  --- Day 7: No Space Left On Device ---
  You can hear birds chirping and raindrops hitting leaves as the expedition proceeds. Occasionally, you can even hear much louder sounds in the distance; how big do the animals get out here, anyway?

  The device the Elves gave you has problems with more than just its communication system. You try to run a system update:

  $ system-update --please --pretty-please-with-sugar-on-top
  Error: No space left on device

  Perhaps you can delete some files to make space for the update?

  You browse around the filesystem to assess the situation and save the resulting terminal output (your puzzle input). For example:

  #{test_input(:part_1)}

  The filesystem consists of a tree of files (plain data) and directories (which can contain other directories or files). The outermost directory is called /. You can navigate around the filesystem, moving into or out of directories and listing the contents of the directory you're currently in.

  Within the terminal output, lines that begin with $ are commands you executed, very much like some modern computers:

  - cd means change directory. This changes which directory is the current directory, but the specific result depends on the argument:

  - cd x moves in one level: it looks in the current directory for the directory named x and makes it the current directory.
  - cd .. moves out one level: it finds the directory that contains the current directory, then makes that directory the current directory.
  - cd / switches the current directory to the outermost directory, /.

  - ls means list. It prints out all of the files and directories immediately contained by the current directory:

  - 123 abc means that the current directory contains a file named abc with size 123.
  - dir xyz means that the current directory contains a directory named xyz.

  Given the commands and output in the example above, you can determine that the filesystem looks visually like this:

  - / (dir)
  - a (dir)
    - e (dir)
      - i (file, size=584)
    - f (file, size=29116)
    - g (file, size=2557)
    - h.lst (file, size=62596)
  - b.txt (file, size=14848514)
  - c.dat (file, size=8504156)
  - d (dir)
    - j (file, size=4060174)
    - d.log (file, size=8033020)
    - d.ext (file, size=5626152)
    - k (file, size=7214296)

  Here, there are four directories: / (the outermost directory), a and d (which are in /), and e (which is in a). These directories also contain files of various sizes.

  Since the disk is full, your first step should probably be to find directories that are good candidates for deletion. To do this, you need to determine the total size of each directory. The total size of a directory is the sum of the sizes of the files it contains, directly or indirectly. (Directories themselves do not count as having any intrinsic size.)

  The total sizes of the directories above can be found as follows:

  - The total size of directory e is 584 because it contains a single file i of size 584 and no other directories.
  - The directory a has total size 94853 because it contains files f (size 29116), g (size 2557), and h.lst (size 62596), plus file i indirectly (a contains e which contains i).
  - Directory d has total size 24933642.
  - As the outermost directory, / contains every file. Its total size is 48381165, the sum of the size of every file.

  To begin, find all of the directories with a total size of at most 100000, then calculate the sum of their total sizes. In the example above, these directories are a and e; the sum of their total sizes is 95437 (94853 + 584). (As in this example, this process can count files more than once!)

  Find all of the directories with a total size of at most 100000. What is the sum of the total sizes of those directories?

  ## Example
    iex> part_1(test_input(:part_1))
    95437

  """
  def_solution part_1(stream_input) do
    stream_input
    |> to_fs_map()
    |> to_dir_sizes(%{})
    |> score()
  end

  @doc """
  --- Part Two ---
  Now, you're ready to choose a directory to delete.

  The total disk space available to the filesystem is 70000000. To run the update, you need unused space of at least 30000000. You need to find a directory you can delete that will free up enough space to run the update.

  In the example above, the total size of the outermost directory (and thus the total amount of used space) is 48381165; this means that the size of the unused space must currently be 21618835, which isn't quite the 30000000 required by the update. Therefore, the update still requires a directory with total size of at least 8381165 to be deleted before it can run.

  To achieve this, you have the following options:

  Delete directory e, which would increase unused space by 584.
  Delete directory a, which would increase unused space by 94853.
  Delete directory d, which would increase unused space by 24933642.
  Delete directory /, which would increase unused space by 48381165.
  Directories e and a are both too small; deleting them would not free up enough space. However, directories d and / are both big enough! Between these, choose the smallest: d, increasing unused space by 24933642.

  Find the smallest directory that, if deleted, would free up enough space on the filesystem to run the update. What is the total size of that directory?

  ## Example
    iex> part_2(test_input(:part_1))
    24933642
  """
  def_solution part_2(stream_input) do
    stream_input
    |> to_fs_map()
    |> to_dir_sizes(%{})
    |> find_dir_to_delete
  end

  defp find_dir_to_delete(dir_size_map) do
    free_space = 70_000_000 - Map.fetch!(dir_size_map, ["/"])
    min_dir_size = 30_000_000 - free_space

    Enum.reduce(dir_size_map, 70_000_000, fn {_name, size}, current_min ->
      cond do
        size < min_dir_size -> current_min
        current_min > size -> size
        :else -> current_min
      end
    end)
  end

  defp score(dir_size_map) do
    dir_size_map
    |> Enum.reduce(0, fn {_, dir_size}, size_acc ->
      if dir_size <= 100_000, do: dir_size + size_acc, else: size_acc
    end)
  end

  defp to_dir_sizes(map, acc) when is_map(map) do
    map
    |> Enum.at(0)
    |> to_dir_sizes([], acc)
  end

  defp to_dir_sizes({name, contents}, path, dir_sizes_acc) do
    Enum.reduce(contents, {dir_sizes_acc, 0}, fn {inner_name, value} = maybe_dir,
                                                 {inner_dir_sizes_acc, size_acc} ->
      if is_integer(value) do
        {inner_dir_sizes_acc, size_acc + value}
      else
        updated_path = [name | path]
        updated_inner_dir_sizes_acc = to_dir_sizes(maybe_dir, updated_path, inner_dir_sizes_acc)

        {updated_inner_dir_sizes_acc,
         size_acc + updated_inner_dir_sizes_acc[get_name(inner_name, updated_path)]}
      end
    end)
    |> then(fn {updated_dir_sizes, total_size} ->
      Map.put(updated_dir_sizes, get_name(name, path), total_size)
    end)
  end

  defp get_name(name, path) do
    [name | path] |> Enum.reverse()
  end

  defp to_fs_map(strem_input) do
    strem_input
    |> Enum.reduce({%{}, []}, &build_fs/2)
    |> elem(0)
  end

  defp build_fs(<<"$ cd /">>, {fs, _position}), do: {fs, ["/"]}
  defp build_fs(<<"$ cd ..">>, {fs, [_ | position]}), do: {fs, position}
  defp build_fs(<<"$ cd ", next::binary()>>, {fs, position}), do: {fs, [next | position]}
  defp build_fs(<<"$ ls">>, acc), do: acc
  defp build_fs(<<"dir ", _dir_name::binary()>>, acc), do: acc

  defp build_fs(file, {fs, position}) do
    [size_string, name] = String.split(file, " ", parts: 2)
    {update_fs(fs, position, name, String.to_integer(size_string)), position}
  end

  defp update_fs(fs, position, name, size) do
    path = Enum.reduce(position, [], &[Access.key(&1, %{}) | &2])
    update_in(fs, path, &Map.put(&1, name, size))
  end

  def test_input(:part_1) do
    """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k

    """
  end
end
