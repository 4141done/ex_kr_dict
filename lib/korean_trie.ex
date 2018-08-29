defmodule KoreanTrie do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, %{children: %{}}}
  end

  def insert(pid, binary) do
    GenServer.cast(pid, {:insert, binary})
  end

  def find(pid, binary) do
    GenServer.call(pid, {:find, binary})
  end

  def prefix(pid, binary) do
    GenServer.call(pid, {:prefix, binary})
  end

  def barf(pid) do
    GenServer.call(pid, :barf)
  end

  def handle_call({:find, binary}, _from, state) do
    {:reply, do_find(state, [], binary), state}
  end

  def handle_call({:prefix, binary}, _from, state) do
    {:reply, do_prefix_search(state, binary, [], state), state}
  end

  def handle_cast({:insert, binary}, state) do
    new_state = do_insert(state, state, [:children], binary)
    {:noreply, new_state}
  end

  def handle_call(:barf, _from, state) do
    {:reply, state, state}
  end

  def gather_prefixes(%{children: children}, _current, found) when children == %{} do
    found
  end

  def gather_prefixes(%{value: val, children: children} = current_node, current, found) do
    children
    |> Enum.flat_map(fn
      {_, %{is_word_boundary: false, value: val} = next_node} ->
        gather_prefixes(next_node, current ++ [val], found)

      {_, %{children: next_children, value: val, is_word_boundary: true} = next_node} ->
        word = List.to_string(current ++ [val])
        gather_prefixes(next_node, current ++ [val], [word | found])
    end)
    # Hack: We get the original prefix multiple times
    |> Enum.uniq()
    |> Enum.sort()
  end

  def gather_prefixes(_node, _current, found), do: []

  defp do_prefix_search(nil, _, _, _), do: {:ok, []}

  defp do_prefix_search(current_node, "", found, root) do
    case do_find(root, [], List.to_string(found)) do
      :not_found ->
        {:ok, gather_prefixes(current_node, found, [])}

      {:ok, word} ->
        {:ok, gather_prefixes(current_node, found, [word])}
    end
  end

  defp do_prefix_search(%{children: children}, <<current::utf8>> <> rest, found, root) do
    case Map.get(children, current) do
      nil -> do_prefix_search(nil, rest, found, root)
      %{value: val} = next_node -> do_prefix_search(next_node, rest, found ++ [val], root)
    end
  end

  defp do_find(%{is_word_boundary: true}, found, ""), do: {:ok, List.to_string(found)}

  defp do_find(_root, _found, ""), do: :not_found

  defp do_find(nil, _, _), do: :not_found

  defp do_find(%{children: children} = current_node, found, <<current::utf8>> <> rest) do
    case Map.get(children, current) do
      nil ->
        do_find(nil, found, rest)

      %{value: val} = next_node ->
        do_find(next_node, found ++ [val], rest)
    end
  end

  defp do_insert(_current_node, root, _path, ""), do: root

  defp do_insert(%{children: children} = current_node, root, path, <<current::utf8>> <> rest) do
    case Map.get(children, current) do
      nil ->
        new_node = %{
          value: current,
          children: %{},
          is_word_boundary: String.length(rest) == 0
        }

        do_insert(
          new_node,
          put_in(root, path ++ [current], new_node),
          path ++ [current, :children],
          rest
        )

      child ->
        do_insert(child, root, path ++ [current, :children], rest)
    end
  end
end
