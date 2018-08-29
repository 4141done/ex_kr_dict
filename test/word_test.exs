defmodule WordTest do
  use ExUnit.Case
  alias KrDict.Util.{Word}

  test "from_hangul_array/1 can assemble a good two character syllable" do
    assert Word.from_hangul_array(["ㄱ", "ㅏ"]) == {:ok, "가"}
  end

  test "from_hangul_array/1 can assemble a good three character syllable" do
    assert Word.from_hangul_array(["ㄱ", "ㅏ", "ㅁ"]) == {:ok, "감"}
  end

  test "from_hangul_array/1 can assemble an ambiguous list of characters we should split on second" do
    assert Word.from_hangul_array(["ㄱ", "ㅏ", "ㅁ", "ㅏ"]) == {:ok, "가마"}
  end

  test "from_hangul_array/1 can assemble an ambiguous list of characters we should split on third" do
    assert Word.from_hangul_array(["ㄱ", "ㅏ", "ㅁ", "ㄱ", "ㅠ", "ㄹ"]) == {:ok, "감귤"}
  end

  test "from_hangul_array/1 will not assemble two onsets" do
    assert {:error, _error_message} = Word.from_hangul_array(["ㄱ", "ㄱ"])
  end

  test "from_hangul_array/1 will not assemble two vowels" do
    assert {:error, _error_message} = Word.from_hangul_array(["ㅏ", "ㅏ"])
  end

  test "from_hangul_array/1 will not assemble two codas" do
    assert {:error, _error_message} = Word.from_hangul_array(["ㄸ", "ㄲ"])
  end

  test "from_hangul_array/1 will not assemble an onset and a coda" do
    assert {:error, _error_message} = Word.from_hangul_array(["ㄱ", "ㄲ"])
  end

  test "from_hangul_array/1 will not assemble starting with a vowel" do
    assert {:error, _error_message} = Word.from_hangul_array(["ㅏ", "ㄱ"])
  end

  test "to_hangul_array/1 converts properly" do
    assert Word.to_hangul_array("공항버스") ==
             {:ok, ["ㄱ", "ㅗ", "ㅇ", "ㅎ", "ㅏ", "ㅇ", "ㅂ", "ㅓ", "ㅅ", "ㅡ"]}
  end

  test "to_hangul_array/1 gives an error if " do
    assert {:error, _message} = Word.to_hangul_array("공ㅇ")
  end
end
