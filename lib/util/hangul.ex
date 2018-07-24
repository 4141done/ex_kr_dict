defmodule KrDict.Util.Hangul do
  alias KrDict.Util.Hangul

  @moduledoc """
  Port of OpenKoreanText - scala twitter
  # 분리 방법 설명: http://divestudy.tistory.com/8 & https://blog.zective.com/2016/01/21/unicode-%EA%B8%B0%EC%A4%80-%ED%95%9C%EA%B8%80-%ED%98%95%ED%83%9C%EC%86%8C-%EB%B6%84%EB%A6%AC%ED%95%98%EA%B8%B0-%EC%A1%B0%ED%95%A9%ED%95%98%EA%B8%B0/
  """

  defstruct [:onset, :vowel, :coda]

  # This is the first hangul occurrence in utf-8: "가" (last is "뿿", 0xBFFF)
  @hangul_base 0xAC00

  # So to get to the next onset, we have to go through all the vowels
  # and all the codas.  For for each vowel, 28 codas which takes us from
  # ㄱ to ㄲ
  # Therefore we can add 588 to whatever grouping we are in to arrive at the same grouping with a onset
  # <<first::utf8>> = "가"
  # "까" = [first + 588] |> List.to_string()
  @onset_base 21 * 28

  # After the onset, we can go 28 forward to reach the next vowel
  # <<first::utf8>> = "가"
  # "개" = [first + 28] |> List.to_string()
  @vowel_base 28

  # onset 감 -> ㄱ. 19개
  @onset_list [
    "ㄱ",
    "ㄲ",
    "ㄴ",
    "ㄷ",
    "ㄸ",
    "ㄹ",
    "ㅁ",
    "ㅂ",
    "ㅃ",
    "ㅅ",
    "ㅆ",
    "ㅇ",
    "ㅈ",
    "ㅉ",
    "ㅊ",
    "ㅋ",
    "ㅌ",
    "ㅍ",
    "ㅎ"
  ]

  # vowel = 감 -> ㅏ. 21개
  @vowel_list [
    "ㅏ",
    "ㅐ",
    "ㅑ",
    "ㅒ",
    "ㅓ",
    "ㅔ",
    "ㅕ",
    "ㅖ",
    "ㅗ",
    "ㅘ",
    "ㅙ",
    "ㅚ",
    "ㅛ",
    "ㅜ",
    "ㅝ",
    "ㅞ",
    "ㅟ",
    "ㅠ",
    "ㅡ",
    "ㅢ",
    "ㅣ"
  ]

  # coda 감 -> ㅁ.  28개
  @coda_list [
    " ",
    "ㄱ",
    "ㄲ",
    "ㄳ",
    "ㄴ",
    "ㄵ",
    "ㄶ",
    "ㄷ",
    "ㄹ",
    "ㄺ",
    "ㄻ",
    "ㄼ",
    "ㄽ",
    "ㄾ",
    "ㄿ",
    "ㅀ",
    "ㅁ",
    "ㅂ",
    "ㅄ",
    "ㅅ",
    "ㅆ",
    "ㅇ",
    "ㅈ",
    "ㅊ",
    "ㅋ",
    "ㅌ",
    "ㅍ",
    "ㅎ"
  ]

  defguard is_valid_hangul(hangul)
           when hangul not in @onset_list and hangul not in @vowel_list and
                  hangul not in @coda_list

  def decompose(<<hangul::utf8>> = hangul_string) when is_valid_hangul(hangul_string) do
    u = hangul - @hangul_base

    %__MODULE__{}
    |> add_onset(u)
    |> add_vowel(u)
    |> add_coda(u)
    |> (&{:ok, &1}).()
  end

  def decompose(bad_hangul), do: {:error, "#{bad_hangul} is not valid hangul"}

  def has_coda?(hangul) do
    case decompose(hangul) do
      {:ok, %{coda: nil}} -> false
      _ -> true
    end
  end

  def compose(%__MODULE__{onset: onset, vowel: vowel, coda: coda}) do
    @hangul_base
    |> compose_onset(onset)
    |> compose_vowel(vowel)
    |> compose_coda(coda)
    |> List.wrap()
    |> List.to_string()
  end

  defp compose_onset(codepoint, onset) do
    onset_index = Enum.find_index(@onset_list, fn item -> item == onset end)
    codepoint + onset_index * @onset_base
  end

  defp compose_vowel(codepoint, vowel) do
    vowel_index = Enum.find_index(@vowel_list, fn item -> item == vowel end)
    codepoint + vowel_index * @vowel_base
  end

  defp compose_coda(codepoint, nil), do: codepoint

  defp compose_coda(codepoint, coda) do
    coda_index = Enum.find_index(@coda_list, fn item -> item == coda end)

    codepoint + coda_index
  end

  defp add_onset(%__MODULE__{} = hangul, u) do
    onset_index = (u / @onset_base) |> trunc()

    Enum.fetch!(@onset_list, onset_index)
    |> (&%__MODULE__{hangul | onset: &1}).()
  end

  defp add_vowel(%__MODULE__{} = hangul, u) do
    vowel_index = (rem(u, @onset_base) / @vowel_base) |> trunc()

    Enum.fetch!(@vowel_list, vowel_index)
    |> (&%__MODULE__{hangul | vowel: &1}).()
  end

  defp add_coda(%__MODULE__{} = hangul, u) do
    coda_index = rem(u, @vowel_base)

    case Enum.fetch!(@coda_list, coda_index) do
      " " -> hangul
      coda -> %__MODULE__{hangul | coda: coda}
    end
  end
end
