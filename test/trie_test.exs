defmodule TrieTest do
  use ExUnit.Case

  setup do
    trie = start_supervised!(Trie)
    %{trie: trie}
  end

  test "can insert a word", %{trie: trie} do
    Trie.insert(trie, "공기")
  end

  test "can insert another word with same initial", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "공기밥")
  end

  test "can insert another word with different initial", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")
  end

  test "can find inserted word", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")

    assert {:ok, "공기"} == Trie.find(trie, "공기")
  end

  test "will not find anything input does not match inserted initial", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")

    assert :not_found = Trie.find(trie, "고양이")
  end

  test "will not find anything if input matches non-intial syllable", %{trie: trie} do
    Trie.insert(trie, "공기")
    Trie.insert(trie, "광화문")

    assert :not_found = Trie.find(trie, "기")
  end
end
