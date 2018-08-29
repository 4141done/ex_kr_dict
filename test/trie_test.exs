defmodule TrieTest do
  use ExUnit.Case
  require IEx

  def barf(%TrieNode{children: children}, result \\ []) do
    children
    |> Enum.reduce(result, fn {val, next}, acc ->
      acc ++ barf(next, [val])
    end)
    |> Enum.map(&List.to_string([&1]))
  end

  test "insert/2 can insert a word" do
    trie = Trie.insert("ㄱㅗㅇㄱㅣ")
    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ"]
  end

  test "insert/2 can insert an existing word" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ"]
  end

  test "insert/2 handles empty string inserts" do
    trie = Trie.insert("")
    assert barf(trie) == []
  end

  test "insert/2 can insert another word with same initial" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣㅂㅏㅂ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ", "ㅂ", "ㅏ", "ㅂ"]
  end

  test "insert/2 can insert another word with different initial" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ", "ㅏ", "ㅇ", "ㅎ", "ㅗ", "ㅏ", "ㅁ", "ㅜ", "ㄴ"]
  end

  test "find/2 can find inserted word" do
    result =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅇㄱㅣ")

    assert result == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ"]
  end

  test "find/2 will not find anything input does not match inserted initial" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅇㅑㅇㅇㅣ")

    assert found == nil
  end

  test " find/2 will not find anything if input matches non-initial syllable" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅣ")

    assert found == nil
  end

  test "find/2 will not match partial non-words" do
    found =
      Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅏㅇ")

    assert found == nil
  end
end
