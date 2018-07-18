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
end
