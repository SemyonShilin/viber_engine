defmodule Engine.ViberTest do
  use ExUnit.Case
  doctest Engine.Viber

  test "greets the world" do
    assert Engine.Viber.hello() == :world
  end
end
