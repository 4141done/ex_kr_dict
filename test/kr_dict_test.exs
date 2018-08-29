defmodule KrDictTest do
  use ExUnit.Case
  doctest KrDict
  gom = "boo"
  @tag :bops
  test "greets the world #{gom}" do
    assert KrDict.hello() == :world
  end
end
