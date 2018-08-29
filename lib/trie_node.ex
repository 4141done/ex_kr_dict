defmodule TrieNode do
  defstruct children: %{}, value: nil, is_word: false, prev: nil

  # put_in(b, [Access.key(:children),  "a", Access.key(:children), "s"], %TrieNode{is_word: true, value: "dork"})
end
