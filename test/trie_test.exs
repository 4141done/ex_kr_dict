defmodule TrieTest do
  use ExUnit.Case

  alias KrDict.{Trie, TrieNode}

  def barf(%TrieNode{children: children}, result \\ []) do
    children
    |> Enum.reduce(result, fn {val, next}, acc ->
      acc ++ barf(next, [val])
    end)
    |> Enum.map(&List.to_string([&1]))
  end

  @tag :trie_insert
  test "insert/2 can insert a word" do
    trie = Trie.insert("공기")
    assert barf(trie) == ["공", "기"]
  end

  test "insert/2 can insert an existing word" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ"]
  end

  @tag :trie_insert
  test "insert/2 handles empty string inserts" do
    trie = Trie.insert("")
    assert barf(trie) == []
  end

  @tag :trie_insert
  test "insert/2 can insert another word with same initial" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣㅂㅏㅂ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ", "ㅂ", "ㅏ", "ㅂ"]
  end

  @tag :trie_insert
  test "insert/2 can insert another word with different initial" do
    trie =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")

    assert barf(trie) == ["ㄱ", "ㅗ", "ㅇ", "ㄱ", "ㅣ", "ㅏ", "ㅇ", "ㅎ", "ㅗ", "ㅏ", "ㅁ", "ㅜ", "ㄴ"]
  end

  @tag :trie_insert
  test "insert/2 marks the last node in the inserted word with is_word: true" do
    trie = Trie.insert("ㄹ")
    |> Trie.insert("ㄱㅗ")

    <<expected_first_value::utf8>> = "ㄹ"

    <<expected_intermediate_value::utf8>> = "ㄱ"
    <<expected_second_value::utf8>> = "ㅗ"

    assert [
      %{
        is_word: true,
        value: ^expected_first_value
      },
      %{
        is_word: false,
        value: ^expected_intermediate_value,
        children: %{
          ^expected_second_value => %{
            value: ^expected_second_value,
            is_word: true
          }
        }
      }
    ] = Map.values(trie.children) |> Enum.sort(&(&1.value >= &2.value))
  end

  @tag :trie_insert
  test "insert/2 marks the last node in the inserted word with is_word: true and node already exists" do
    trie = Trie.insert("ㄱㅗ")
    |> Trie.insert("ㄱ")

    <<expected_first_value::utf8>> = "ㄱ"
    <<expected_second_value::utf8>> = "ㅗ"

    assert [
      %{
        is_word: true,
        value: ^expected_first_value,
        children: %{
          ^expected_second_value => %{
            is_word: true,
            value: ^expected_second_value
          }
        }
      },
    ] = Map.values(trie.children) |> Enum.sort(&(&1.value >= &2.value))
  end

  @tag :trie_find
  test "find/3 can find inserted word" do
    result =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅇㄱㅣ")

    assert result == "ㄱㅗㅇㄱㅣ"
  end

  @tag :trie_find
  test "find/3 will not find anything input does not match inserted initial" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅇㅑㅇㅇㅣ")

    assert found == nil
  end

  @tag :trie_find
  test " find/3 will not find anything if input matches non-initial syllable" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅣ")

    assert found == nil
  end

  @tag :trie_find
  test "find/3 will not match partial non-words" do
    found =
      Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.find("ㄱㅗㅏㅇ")

    assert found == nil
  end

  @tag :trie_find
  test "find/3 will return the current node if `include_node` option passed" do
    found =
      Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.insert("ㄱㅗㅏㅇ")
      |> Trie.find("ㄱㅗㅏㅇ", include_node: true)
    <<expected_value::utf8>> = "ㅇ"
    assert {%TrieNode{value: ^expected_value}, "ㄱㅗㅏㅇ"} = found
  end

  @tag :trie_find
  test "find/3 will return nil for the node if `include_node` option passed and the query does not exist in the trie" do
    found =
      Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.insert("ㄱㅗㅏㅇ")
      |> Trie.find("ㅂㅏㄱ", include_node: true)
    assert {nil, nil} == found
  end

  @tag :trie_find
  test "find/3 will return the current node if `include_node` option passed and the query is not a word" do
    found =
      Trie.insert("ㄱㅗㅏㅇㅎㅗㅏㅁㅜㄴ")
      |> Trie.insert("ㄱㅗㅏㅇ")
      |> Trie.find("ㄱㅗㅏ", include_node: true)
    <<expected_value::utf8>> = "ㅏ"
    assert {%TrieNode{value: ^expected_value}, nil} = found
  end

  @tag :trie_prefix
  test "prefix/3 deals with empty string" do
    found =
      Trie.insert("ㄱㅗㅇㄱㅣ")
      |> Trie.insert("ㄱㅗㅇㄱㅣㅂㅏㅂ")
      |> Trie.insert("ㄱㅗㅇㅎㅏㅇㅂㅓㅅㅡ")
      |> Trie.prefix("")

    assert found == []
  end

  @tag :trie_prefix
  test "prefix/3 find a word if only one word that shares the prefix" do
    found = Trie.insert("공")
      |> Trie.insert("밥")
      |> Trie.insert("판다")
      |> Trie.prefix("공")
    assert found == ["공"]
  end

  @tag :trie_prefix
  test "prefix/3 find any words that share a prefix" do
    found = Trie.insert("공")
      |> Trie.insert("밥")
      |> Trie.insert("공기밥")
      |> Trie.insert("공기")
      |> Trie.prefix("공")

    assert found == ["공", "공기", "공기밥"]
  end

  @tag :trie_prefix
  test "prefix/3 will return the prefix as well if it is a word" do
    found = Trie.insert("공기")
    |> Trie.insert("공기밥")
    |> Trie.insert("공항버스")
    |> Trie.prefix("공기")

    assert found == ["공기", "공기밥"]
  end

  @tag :trie_prefix
  test "prefix/3 will not return the prefix as well if it is not a word" do
   found = Trie.insert("공기")
    |> Trie.insert("공기밥")
    |> Trie.insert("공항버스")
    |> Trie.prefix("공항버")

    assert found == ["공항버스"]
  end

  @tag :trie_prefix
  test "prefix/3 will not return anything if there are no matching prefixes" do
   found = Trie.insert("공기")
    |> Trie.insert("공기밥")
    |> Trie.insert("공항버스")
    |> Trie.prefix("물")

    assert found == []
  end
end
