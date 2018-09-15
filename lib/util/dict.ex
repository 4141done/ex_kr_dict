defmodule KrDict.Util.Dict do
  alias KrDict.Util.Word
  alias KrDict.{Trie, TrieNode}

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
