defmodule Trie do
  def insert(to_insert) do
    insert(%TrieNode{}, to_insert)
  end

  def insert(current_node, to_insert) do
    insert(current_node, [], current_node, to_insert)
  end

  def insert(_current_node, _path, root, "") do
    root
  end

  def insert(%TrieNode{children: children}, path, root, <<char::utf8>> <> rest) do
    new_path = path ++ [char]
    accessor = [Access.key(:children) | Enum.intersperse(new_path, Access.key(:children))]

    case Map.get(children, char) do
      nil ->
        next_node = %TrieNode{value: char, is_word: String.length(rest) == 0}

        insert(
          next_node,
          path ++ [char],
          put_in(root, accessor, next_node),
          rest
        )

      next_node ->
        insert(next_node, new_path, root, rest)
    end
  end

  def find(%TrieNode{} = trie, query) do
    find(trie, [], query)
  end

  def find(%TrieNode{is_word: true}, found, "") do
    found
    |> Enum.reverse()
    |> Enum.map(&List.to_string([&1]))
  end

  def find(_t, _found, "") do
    nil
  end

  def find(%TrieNode{children: children} = current_node, found, <<char::utf8>> <> rest) do
    case Map.get(children, char) do
      nil ->
        nil

      next_node ->
        find(%{next_node | prev: current_node}, [char | found], rest)
    end
  end
end
