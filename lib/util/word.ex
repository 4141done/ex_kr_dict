defmodule KrDict.Util.Word do
  alias KrDict.Util.Hangul
  import KrDict.Util.Hangul, only: [valid_onset?: 1, valid_vowel?: 1, valid_coda?: 1]

  def from_hangul_array(hangul) do
    from_hangul_array(hangul, "")
  end

  def from_hangul_array([], result) do
    {:ok, result}
  end

  def from_hangul_array([onset, vowel, potential_onset, potential_vowel | rest], result)
      when valid_onset?(onset) and valid_vowel?(vowel) and valid_vowel?(potential_vowel) do
    syllable = %Hangul{onset: onset, vowel: vowel} |> Hangul.compose()
    from_hangul_array([potential_onset, potential_vowel | rest], result <> syllable)
  end

  def from_hangul_array([onset, vowel, coda | rest], result)
      when valid_onset?(onset) and valid_vowel?(vowel) and valid_coda?(coda) do
    syllable = %Hangul{onset: onset, vowel: vowel, coda: coda} |> Hangul.compose()
    from_hangul_array(rest, result <> syllable)
  end

  def from_hangul_array([onset, vowel | rest], result)
      when Hangul.valid_onset?(onset) and Hangul.valid_vowel?(vowel) do
    syllable = %Hangul{onset: onset, vowel: vowel} |> Hangul.compose()
    from_hangul_array(rest, result <> syllable)
  end

  def from_hangul_array(list, _result), do: {:error, "Invalid Hangul #{inspect(list)}"}

  def to_hangul_array(chars) do
    result = chars
    |> String.graphemes()
    |> Enum.map(&Hangul.decompose/1)
    |> Enum.flat_map(fn
      {:ok, %KrDict.Util.Hangul{onset: onset, vowel: vowel, coda: nil}} ->
        [onset, vowel]
      {:ok, %KrDict.Util.Hangul{onset: onset, vowel: vowel, coda: coda}} ->
        [onset, vowel, coda]
      {:error, _message} ->
        [:error]
    end)

    case Enum.find(result, fn char -> char == :error end) do
      nil -> {:ok, result}
      _other -> {:error, "bad hangul"}
    end
  end

end
