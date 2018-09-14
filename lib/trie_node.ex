defmodule KrDict.TrieNode do
  defstruct children: %{}, value: nil, is_word: false, prev: nil
end
