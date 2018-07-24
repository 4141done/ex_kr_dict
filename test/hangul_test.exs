defmodule HangulTest do
  use ExUnit.Case
  alias KrDict.Util.Hangul

  test "decompose/1 can decompose a two character syllable" do
    assert {:ok, %Hangul{onset: "ㄱ", vowel: "ㅏ", coda: nil}} = Hangul.decompose("가")
  end

  test "decompose/1 can decompose a three character syllable" do
    assert {:ok, %Hangul{onset: "ㄱ", vowel: "ㅏ", coda: "ㅁ"}} = Hangul.decompose("감")
  end

  test "decompose/1 can decompose a four character syllable" do
    assert {:ok, %Hangul{onset: "ㄱ", vowel: "ㅏ", coda: "ㅄ"}} = Hangul.decompose("값")
  end

  test "decompose/1 rejects single onset" do
    assert {:error, _message} = Hangul.decompose("ㄱ")
  end

  test "compose/1 can put together with an onset and a vowel" do
    assert "가" = Hangul.compose(%Hangul{onset: "ㄱ", vowel: "ㅏ"})
  end

  test "compose/1 can put together with an onset, vowel, and coda" do
    assert "감" = Hangul.compose(%Hangul{onset: "ㄱ", vowel: "ㅏ", coda: "ㅁ"})
  end

  test "has_coda?/1 returns true for a syllable with a coda" do
    assert true == Hangul.has_coda?("감")
  end

  test "has_coda?/1 returns false for a syllable with no coda" do
    assert false == Hangul.has_coda?("가")
  end
end
