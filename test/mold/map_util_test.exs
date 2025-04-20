defmodule Mold.MapUtilTest do
  use ExUnit.Case, async: true
  alias Mold.MapUtil

  describe "to_atom_keys/1" do
    test "converts string keys to atom keys" do
      input = %{"name" => "John", "age" => 30}
      expected = %{name: "John", age: 30}

      assert MapUtil.to_atom_keys(input) == expected
    end

    test "keeps existing atom keys unchanged" do
      input = %{name: "John", age: 30}
      expected = %{name: "John", age: 30}

      assert MapUtil.to_atom_keys(input) == expected
    end

    test "raises error for invalid key types" do
      input = %{1 => "value"}

      assert_raise ArgumentError, fn ->
        MapUtil.to_atom_keys(input)
      end
    end
  end
end
