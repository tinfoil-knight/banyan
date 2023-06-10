defmodule BanyanTest do
  use ExUnit.Case
  doctest Banyan

  test "greets the world" do
    assert Banyan.hello() == :world
  end
end
