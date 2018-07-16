defmodule TrieTest do
  use ExUnit.Case

  setup do
    trie = start_supervised!(Trie)
    %{trie: trie}
  end

  test "insert/2 can insert a word", %{trie: trie} do
    Trie.insert(trie, "공기")
  end

  test "insert/2 can insert another word with same initial", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "공기밥")
  end

  test "insert/2 can insert another word with different initial", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")
  end

  test "find/2 can find inserted word", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")

    assert {:ok, "공기"} == Trie.find(trie, "공기")
  end

  test "find/2 will not find anything input does not match inserted initial", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")

    assert :not_found = Trie.find(trie, "고양이")
  end

  test " find/2will not find anything if input matches non-intial syllable", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")

    assert :not_found = Trie.find(trie, "기")
  end

  test "find/2 will not match partial non-words", %{trie: trie} do
    Trie.insert(trie, "광화문")
    assert :not_found == Trie.find(trie, "광")
  end

  test "prefix/2 find any words that share a prefix", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "공기밥")
    Trie.insert(trie, "공항버스")

    assert {:ok, ["공기", "공기밥", "공항버스"]} = Trie.prefix(trie, "공")
  end
end
