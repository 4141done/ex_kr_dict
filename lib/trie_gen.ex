defmodule TrieGen do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %TrieNode{}}
  end

  def insert(pid, binary) do
    GenServer.cast(pid, {:insert, binary})
  end

  def find(pid, binary) do
    GenServer.call(pid, {:find, binary})
  end

  def barf(pid) do
    GenServer.call(pid, :barf)
  end

  ##########
  # SERVER #
  ##########

  def handle_cast({:insert, binary}, state) do
    {:noreply, do_insert(state, [], state, binary)}
  end

  def handle_call({:find, binary}, _from, state) do
    {:reply, do_find(state, [], binary), state}
  end

  def handle_call(:barf, _from, state) do
    {:reply, state, state}
  end

  ############
  # Internal #
  ############
  defp do_insert(_current_node, path, root, "") do
    root
  end

  defp do_insert(%TrieNode{children: children}, path, root, <<char::utf8>> <> rest) do
    new_path = path ++ [char]
    accessor = [Access.key(:children) | Enum.intersperse(new_path, Access.key(:children))]

    case Map.get(children, char) do
      nil ->
        if String.length(rest) == 0 do
          IO.puts("INSERT WORD AT #{List.to_string([char])}")
        end

        next_node = %TrieNode{value: char, is_word: String.length(rest) == 0}

        do_insert(
          next_node,
          path ++ [char],
          put_in(root, accessor, next_node),
          rest
        )

      next_node ->
        do_insert(next_node, new_path, root, rest)
    end
  end

  defp do_find(%{prev: %TrieNode{is_word: true}}, found, "") do
    found
    |> Enum.reverse()
    |> Enum.map(&List.to_string([&1]))
    |> (&{:ok, &1}).()
  end

  defp do_find(_, _found, "") do
    :not_found
  end

  defp do_find(%TrieNode{children: children} = current_node, found, <<char::utf8>> <> rest) do
    if String.length(rest) == 0 do
      IO.puts("at last in find")
      IO.inspect(current_node)
    end

    case Map.get(children, char) do
      nil -> :not_found
      next_node -> do_find(%{next_node | prev: current_node}, [char | found], rest)
    end
  end
end
