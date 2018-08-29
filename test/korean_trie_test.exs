defmodule KoreanTrieTest do
  use ExUnit.Case

  setup do
    korean_trie = start_supervised!(KoreanTrie)
    %{korean_trie: korean_trie}
  end

  test "insert/2 can insert a word", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "공기")
  end

  test "insert/2 can insert another word with same initial", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "공기밥")
  end

  test "insert/2 can insert another word with different initial", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "광화문")
  end

  test "find/2 can find inserted word", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "광화문")

    assert {:ok, "공기"} == KoreanTrie.find(korean_trie, "공기")
  end

  test "find/2 will not find anything input does not match inserted initial", %{
    korean_trie: korean_trie
  } do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "광화문")

    assert :not_found = KoreanTrie.find(korean_trie, "고양이")
  end

  test " find/2will not find anything if input matches non-intial syllable", %{
    korean_trie: korean_trie
  } do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "광화문")

    assert :not_found = KoreanTrie.find(korean_trie, "기")
  end

  test "find/2 will not match partial non-words", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "광화문")
    assert :not_found == KoreanTrie.find(korean_trie, "광")
  end

  test "prefix/2 deals with empty string", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "공기밥")
    KoreanTrie.insert(korean_trie, "공항버스")

    assert {:ok, []} = KoreanTrie.prefix(korean_trie, "")
  end

  test "prefix/2 find any words that share a prefix", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "공기밥")
    KoreanTrie.insert(korean_trie, "공항버스")

    assert {:ok, ["공기", "공기밥", "공항버스"]} = KoreanTrie.prefix(korean_trie, "공")
  end

  test "prefix/2 will return the prefix as well if it is a word", %{korean_trie: korean_trie} do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "공기밥")
    KoreanTrie.insert(korean_trie, "공항버스")

    assert {:ok, ["공기", "공기밥"]} = KoreanTrie.prefix(korean_trie, "공기")
  end

  @tag :bad
  test "prefix/2 will not return the prefix as well if it is not a word", %{
    korean_trie: korean_trie
  } do
    KoreanTrie.insert(korean_trie, "공기")
    KoreanTrie.insert(korean_trie, "공기밥")
    KoreanTrie.insert(korean_trie, "공항버스")

    assert {:ok, ["공항버스"]} = KoreanTrie.prefix(korean_trie, "공항버")
  end
end
