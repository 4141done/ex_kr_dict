defmodule KrDict.Stemming.Sentence do
  defstruct words: [], total_length: 0
end

defmodule KrDict.Stemming.SentenceWord do
  defstruct [:original_form, :stem, :position]

  def build(original_form, position) do
    %__MODULE__{original_form: original_form, position: position}
  end
end

defmodule KrDict.Stemming.Stemmer do
  alias KrDict.Stemming.{Sentence, SentenceWord}
  alias KrDict.{Trie, TrieNode}

  def naive_dictionary(word) do
    IO.puts("--> #{inspect(word)}")
    naive_dictionary(MyDict.prefix(word), word, word)
  end

  def naive_dictionary([], "", original) do
    {original, original}
  end

  def naive_dictionary([], word, original) do
    [removed | rest] = String.graphemes(word) |> Enum.reverse()

    search_segment =
      rest
      |> Enum.reverse()
      |> Enum.join("")

    search_segment
    |> MyDict.prefix()
    |> naive_dictionary(search_segment, original)
  end

  def naive_dictionary([match | rest], substring, original) do
    segment_size = byte_size(substring)
    <<_::bytes-size(segment_size), removed_segment::binary>> = original

    {match, original}
  end

  # Note that the word positions are going to shift as we break up words.  How to handle that?
  # Maybe not explicitly recording the position is better and leaning on a datastructure would be better
  def parse_sentence(sentence) do
    sentence
    |> String.split(" ")
    |> Enum.reduce({0, %Sentence{}}, fn word, {idx, acc} ->
      {idx + 1, %{acc | words: [SentenceWord.build(word, idx) | acc.words]}}
    end)
    |> (fn {sentence_length, built_sentence} ->
          %{
            built_sentence
            | total_length: sentence_length,
              words: built_sentence.words |> Enum.reverse()
          }
        end).()
  end
end
