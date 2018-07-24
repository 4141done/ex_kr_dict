defmodule KrDict.Util.Hangul do
  @moduledoc """
  Port of OpenKoreanText - scala twitter
  """

  defstruct [:onset, :vowel, :coda]

  # This is the first hangul occurrence in utf-8: "가" (last is "뿿", 0xBFFF)
  @hangul_base 0xAC00

  # Todo: understand this and why the multiplication.  Likely UTF-8 beginning of onsets
  @onset_base 21 * 28

  # Todo: understand this.  Likely UTF-8 beginning of vowels
  @vowel_base 28

  # Todo: understand why we don"t care about coda base.  Can we solve some of these issue with 값attern matching?

  # onset 감 -> ㄱ
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

  # vowel = 감 -> ㅏ
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

  # coda 감 -> ㅁ
  # todo: fix seperated coda
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

    {:ok,
     %__MODULE__{
       onset: Enum.fetch!(@onset_list, (u / @onset_base) |> trunc),
       vowel: Enum.fetch!(@vowel_list, (rem(u, @onset_base) / @vowel_base) |> trunc),
       coda:
         case Enum.fetch!(@coda_list, rem(u, @vowel_base)) do
           " " -> nil
           other -> other
         end
     }}
  end

  def decompose(bad_hangul), do: {:error, "#{bad_hangul} is not valid hangul"}

  def has_coda?(hangul) do
  end

  def compose(%__MODULE__{onset: onset, vowel: vowel, coda: coda}) do
  end
end
