defmodule AmbassadorTest do
  use ExUnit.Case
  doctest Ambassador

  test "greets the world" do
    assert Ambassador.hello() == :world
  end
end
