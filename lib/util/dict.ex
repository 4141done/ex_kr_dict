defmodule KrDict.Util.Dict do
  alias KrDict.Util.Word
  alias KrDict.{Trie, TrieNode}

# Loaded kengdict_2011.tsv with hangul broken up and without
# find, prefix args: "ㄱㅗㅇㅎㅏㅇ", "공항"
# insert args: "ㄱㅗㅇㅎㅏㅇㅂㅓㅅㅡㄷㅏ", "공항버스다"
# "Hangul" has many more data points per input, but the idea is to measure
# performance with real operations
# +----------+------------------+------------+-------------+-------------+
# |  Method  | size (flat_size) |    find    |   prefix    |   insert    |
# +----------+------------------+------------+-------------+-------------+
# | hangul   | 42.589264mb      | 4.43 μs/op | 16.06 μs/op | 11.35 μs/op |
# | syllable | 21.157016mb      | 2.41 μs/op | 7.11 μs/op  | 4.4 μs/op   |
# +----------+------------------+------------+-------------+-------------+

  def load(file_path) do
    File.stream!(file_path)
    |> CSV.decode!(separator: ?\t)
    |> Enum.reduce(%TrieNode{}, fn [_, word | _rest], acc ->
      IO.puts(word)

      case word =~ ~r/\s|\d|[.,\/#!$%\^&\*;:{}=\-_`~()\?'"<>]|[a-zA-Z]/ do
        false ->
          case Word.to_hangul_array(word) do
            {:ok, hangul_array} ->
              to_insert = Enum.join(hangul_array)
              Trie.insert(acc, to_insert)

            {:error, error} ->
              IO.puts("Errored on #{word}: #{inspect(error)}")
              acc
          end

        true ->
          acc
      end
    end)
  end

  def load_syllables(file_path) do
    File.stream!(file_path)
    |> CSV.decode!(separator: ?\t)
    |> Enum.reduce(%TrieNode{}, fn [_, word | _rest], acc ->
      case word =~ ~r/\s|\d|[.,\/#!$%\^&\*;:{}=\-_`~()\?'"<>]|[a-zA-Z]/ do
        false ->
          Trie.insert(acc, word)

        true ->
          acc
      end
    end)
  end
end
