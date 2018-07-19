defmodule Trie do
  use GenServer

  defstruct children: %{}, value: nil, is_word_boundary: false

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
    {:reply, do_find(state, [], binary), state}
  end

  def handle_cast({:insert, binary}, state) do
    new_state = do_insert(state, state, [:children], binary)
    {:noreply, new_state}
  end

  def handle_call(:barf, _from, state) do
    {:reply, state, state}
  end

  defp do_find(%{is_word_boundary: true}, found, ""), do: {:ok, List.to_string(found)}

  defp do_find(%{is_word_boundary: false}, _found, ""), do: :not_found

  defp do_find(nil, _, _), do: :not_found

  defp do_find(%{children: children} = current_node, found, <<current::utf8>> <> rest) do
    case Map.get(children, current) do
      nil ->
        do_find(nil, found, rest)
      %{value: val} = next_node ->
        IO.puts "-> #{val}"
        do_find(next_node, found ++ [val], rest)
    end
  end

  defp do_insert(_current_node, root, _path, ""), do: root

  defp do_insert(%{children: children} = current_node, root, path, <<current::utf8>> <> rest) do
    case Map.get(children, current) do
      nil ->
        IO.puts("new node")
        IO.inspect(path)
        new_node = %{
          value: current,
          children: %{},
          is_word_boundary: String.length(rest) == 0
        }
        do_insert(new_node, put_in(root, path ++ [current], new_node), path ++ [current, :children], rest)
      child ->
        IO.puts("found child")
        IO.inspect(path)
        do_insert(child, root, path ++ [current, :children], rest)
    end
  end
end
