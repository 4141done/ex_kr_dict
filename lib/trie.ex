defmodule KrDict.Trie do
  alias KrDict.TrieNode
  @moduledoc """
  A general purpose autocomplete/lookup trie
  """

  @doc """
  Insert some string into the trie.

  Returns `%Trie{}`

  ## Examples

      iex> Trie.insert("안녕")
      %Trie{}

  """
  def insert(current_node \\ %TrieNode{}, to_insert) do
    case to_insert do
      "" -> current_node
      _ -> insert(current_node, [], current_node, to_insert)
    end
  end

  def insert(%TrieNode{is_word: true}, _path, root, "") do
    root
  end

  def insert(%TrieNode{is_word: false} = current_node, path, root, "") do
    put_in(root, build_accessor(path), %{current_node | is_word: true})
  end

  def insert(%TrieNode{children: children}, path, root, <<char::utf8>> <> rest) do
    new_path = path ++ [char]

    case Map.get(children, char) do
      nil ->
        next_node = %TrieNode{value: char, is_word: String.length(rest) == 0}

        insert(
          next_node,
          path ++ [char],
          put_in(root, build_accessor(new_path), next_node),
          rest
        )

      next_node ->
        insert(next_node, new_path, root, rest)
    end
  end

  defp build_accessor(path) do
    [Access.key(:children) | Enum.intersperse(path, Access.key(:children))]
  end

  @doc """
  Finds an exact match for the query in the given trie

  Returns a match or `nil`.

  ## Examples

      iex> Trie.insert("안녕")
      iex> |> Trie.find("안녕")
      "안녕"
  """
  def find(%TrieNode{} = trie, query, opts \\ []) do
    find(trie, [], query, opts)
  end

  def find(%TrieNode{is_word: true} = node, found, "", opts) do
    build_find_result(node, found, opts)
  end

  def find(t, _found, "", opts) do
    build_find_result(t, nil, opts)
  end

  def find(%TrieNode{children: children} = current_node, found, <<char::utf8>> <> rest, opts) do
    case Map.get(children, char) do
      nil ->
        build_find_result(current_node, nil, opts)

      next_node ->
        find(%{next_node | prev: current_node}, [char | found], rest, opts)
    end
  end

  defp build_find_result(node, nil, [include_node: true]), do: {node, nil}

  defp build_find_result(_node, nil, _opts), do: nil

  defp build_find_result(node, result, opts) do
    found = result
      |> Enum.reverse()
      |> Enum.map(&List.to_string([&1]))
      |> Enum.join()

    case opts do
      [include_node: true] ->
        {node, found}

      _ ->
        found
    end
  end

  @doc """
  Find all words that start with a certain binary. If the provided binary is
  also a word, it will be returned as well.

  Returns a list of results

  ## Examples

      iex> Trie.insert("밥")
      iex> |> Trie.insert("밥상")
      iex> |> Trie.insert("상어")
      iex> |> Trie.prefix("밥")
      ["밥", "밥상"]
  """
  def prefix(_, ""), do: []

  def prefix(trie, query) do
    case find(trie, query, include_node: true) do
      {%TrieNode{children: children}, _match} when children == %{} ->
        [query]

      {%TrieNode{children: children}, nil} ->
        children
        |> Enum.flat_map(fn {val, node} ->
          prefix(node, query <> <<val::utf8>>)
        end)

      {%TrieNode{children: children}, match} ->
        children
        |> Enum.flat_map(fn {val, _node} ->
          [match] ++ prefix(trie, match <> <<val::utf8>>)
        end)
    end
  end
end
