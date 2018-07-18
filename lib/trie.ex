defmodule Trie do
  use GenServer

  defstruct children: %{}, value: nil, root: nil

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

  def handle_call(:barf, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:find, binary}, _from, state) do
    {:reply, do_find(state, [], binary), state}
  end

  def handle_call({:prefix, binary}, _from, state) do
  end

  def handle_cast({:insert, binary}, state) do
    new_state = do_insert(state, state, [:children], binary)
    {:noreply, new_state}
  end

  # defp find_after(%{children: children} = current_node, found) do
  #   children
  #   |> Enum.map(fn (key, val) ->
  #   end)
  # end

  defp do_find(nil, _, _), do: :not_found
  defp do_find(_current_node, found, ""), do: {:ok, List.to_string(found)}
  defp do_find(%{children: children} = current_node, found, binary) do
    case Map.get(children, binary) do
      nil ->
        do_find(nil, found, binary)
      %{value: val} ->
        {:ok, val}
    end
  end

  defp do_insert(%{children: children} = current_node, root, path, binary) do
    case Map.get(children, binary) do
      nil ->
        put_in(root, path ++ [binary], %{value: binary, children: %{}})
      child ->
        do_insert(child, root, path ++ [binary, :children], binary)
    end
  end
end
