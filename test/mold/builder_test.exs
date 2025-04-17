defmodule Mold.BuilderTest do
  use ExUnit.Case, async: true

  alias Mold.Builder

  describe "build_string/2" do
    test "converts value to string" do
      assert {:ok, "test"} = Builder.build_string("test", [])
      assert {:ok, "123"} = Builder.build_string(123, [])
      assert {:ok, "123.45"} = Builder.build_string(123.45, [])
    end

    test "returns error for invalid value" do
      assert {:error, _} = Builder.build_string(nil, [])
      assert {:error, _} = Builder.build_string([], [])
    end
  end

  describe "build_integer/2" do
    test "converts value to integer" do
      assert {:ok, 123} = Builder.build_integer(123, [])
      assert {:ok, 123} = Builder.build_integer("123", [])
    end

    test "returns error for invalid value" do
      assert {:error, _} = Builder.build_integer(123.45, [])
      assert {:error, _} = Builder.build_integer(nil, [])
      assert {:error, _} = Builder.build_integer([], [])
      assert {:error, _} = Builder.build_integer("abc", [])
    end
  end

  describe "build_float/2" do
    test "converts value to float" do
      assert {:ok, 123.45} = Builder.build_float(123.45, [])
      assert {:ok, 123.45} = Builder.build_float("123.45", [])
    end

    test "returns error for invalid value" do
      assert {:error, _} = Builder.build_float(123, [])
      assert {:error, _} = Builder.build_float(nil, [])
      assert {:error, _} = Builder.build_float([], [])
      assert {:error, _} = Builder.build_float("abc", [])
    end
  end

  describe "build_boolean/2" do
    test "converts value to boolean" do
      assert {:ok, true} = Builder.build_boolean(true, [])
      assert {:ok, false} = Builder.build_boolean(false, [])
      assert {:ok, true} = Builder.build_boolean("true", [])
      assert {:ok, false} = Builder.build_boolean("false", [])
    end

    test "returns error for invalid value" do
      assert {:error, _} = Builder.build_boolean(nil, [])
      assert {:error, _} = Builder.build_boolean([], [])
      assert {:error, _} = Builder.build_boolean("abc", [])
    end
  end

  describe "build_atom/2" do
    test "returns the atom value" do
      assert {:ok, :test} = Builder.build_atom(:test, [])
    end

    test "returns error for non-atom value" do
      assert {:error, _} = Builder.build_atom([], [])
      assert {:error, _} = Builder.build_atom("abc", [])
    end
  end
end
