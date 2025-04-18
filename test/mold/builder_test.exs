defmodule Mold.BuilderTest do
  use ExUnit.Case, async: true

  alias Mold.Builder

  describe "build/2" do
    test "builds a map with valid values" do
      schema = [
        {:name, :string, required: true},
        {:age, :integer, required: true},
        {:height, :float, default: 1.75},
        {:active, :boolean, default: false},
        {:note, :string, []}
      ]

      params = %{
        name: "John Doe",
        age: 30,
        height: 1.80,
        active: true
      }

      assert {:ok, result} = Builder.build(schema, params)
      assert result == %{name: "John Doe", age: 30, height: 1.80, active: true, note: nil}
    end

    test "returns error for missing required keys" do
      schema = [
        {:name, :string, required: true},
        {:age, :integer, required: true}
      ]

      params = %{name: "John Doe"}

      assert {:error, errors} = Builder.build(schema, params)
      assert errors == [age: "Missing required key"]
    end

    test "returns error for invalid values" do
      schema = [
        {:age, :integer, required: true}
      ]

      params = %{age: "not an integer"}

      assert {:error, errors} = Builder.build(schema, params)
      assert errors == [age: "Invalid integer value: \"not an integer\""]
    end

    test "returns multiple errors" do
      schema = [
        {:age, :integer, required: true},
        {:name, :string, required: true}
      ]

      params = %{name: nil, age: "not an integer"}

      assert {:error, errors} = Builder.build(schema, params)

      assert errors == [
               name: "Missing required key",
               age: "Invalid integer value: \"not an integer\""
             ]
    end
  end

  describe "get_value/3" do
    test "returns value of existing key" do
      assert {:ok, "value"} = Builder.get_value(%{key: "value"}, :key, required: true)
      assert {:ok, "value"} = Builder.get_value(%{key: "value"}, :key, required: false)
    end

    test "returns default value for missing key" do
      assert {:ok, "default"} = Builder.get_value(%{}, :key, default: "default")
    end

    test "returns nil for missing key with no default if not required" do
      assert {:ok, nil} = Builder.get_value(%{}, :key, required: false)
    end

    test "returns error for missing required key" do
      assert {:error, "Missing required key"} = Builder.get_value(%{}, :key, required: true)
    end

    test "returns error for nil value if required" do
      assert {:error, "Missing required key"} =
               Builder.get_value(%{key: nil}, :key, required: true)
    end
  end

  describe "build_string/2" do
    test "converts value to string" do
      assert {:ok, "test"} = Builder.build_string("test", [])
      assert {:ok, "123"} = Builder.build_string(123, [])
      assert {:ok, "123.45"} = Builder.build_string(123.45, [])
    end

    test "returns error for invalid value" do
      assert {:error, "Invalid string value: nil"} = Builder.build_string(nil, [])
      assert {:error, "Invalid string value: []"} = Builder.build_string([], [])
    end
  end

  describe "build_integer/2" do
    test "converts value to integer" do
      assert {:ok, 123} = Builder.build_integer(123, [])
      assert {:ok, 123} = Builder.build_integer("123", [])
    end

    test "returns error for invalid value" do
      assert {:error, "Invalid integer value: 123.45"} = Builder.build_integer(123.45, [])
      assert {:error, "Invalid integer value: nil"} = Builder.build_integer(nil, [])
      assert {:error, "Invalid integer value: []"} = Builder.build_integer([], [])
      assert {:error, "Invalid integer value: \"abc\""} = Builder.build_integer("abc", [])
    end
  end

  describe "build_float/2" do
    test "converts value to float" do
      assert {:ok, 123.45} = Builder.build_float(123.45, [])
      assert {:ok, 123.45} = Builder.build_float("123.45", [])
    end

    test "returns error for invalid value" do
      assert {:error, "Invalid float value: 123"} = Builder.build_float(123, [])
      assert {:error, "Invalid float value: nil"} = Builder.build_float(nil, [])
      assert {:error, "Invalid float value: []"} = Builder.build_float([], [])
      assert {:error, "Invalid float value: \"abc\""} = Builder.build_float("abc", [])
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
      assert {:error, "Invalid boolean value: nil"} = Builder.build_boolean(nil, [])
      assert {:error, "Invalid boolean value: []"} = Builder.build_boolean([], [])
      assert {:error, "Invalid boolean value: \"abc\""} = Builder.build_boolean("abc", [])
    end
  end

  describe "build_atom/2" do
    test "returns the atom value" do
      assert {:ok, :test} = Builder.build_atom(:test, [])
    end

    test "returns error for non-atom value" do
      assert {:error, "Invalid atom value: []"} = Builder.build_atom([], [])
      assert {:error, "Invalid atom value: \"abc\""} = Builder.build_atom("abc", [])
    end
  end

  describe "build_time/2" do
    test "returns the time value" do
      assert {:ok, ~T[12:34:56]} = Builder.build_time(~T[12:34:56], [])
      assert {:ok, ~T[12:34:56]} = Builder.build_time("12:34:56", [])
      assert {:ok, ~T[12:34:56]} = Builder.build_time(~U[2023-10-01 12:34:56Z], [])
    end

    test "returns error for non-time value" do
      assert {:error, "Given value is not ISO8601 format: \"45:67:89\""} =
               Builder.build_time("45:67:89", [])

      assert {:error, "Invalid time value: []"} = Builder.build_time([], [])
    end
  end

  describe "build_date/2" do
    test "returns the date value" do
      assert {:ok, ~D[2023-10-01]} = Builder.build_date(~D[2023-10-01], [])
      assert {:ok, ~D[2023-10-01]} = Builder.build_date("2023-10-01", [])
      assert {:ok, ~D[2023-10-01]} = Builder.build_date(~U[2023-10-01 12:34:56Z], [])
    end

    test "returns error for non-date value" do
      assert {:error, "Given value is not ISO8601 format: \"2023-10-32\""} =
               Builder.build_date("2023-10-32", [])

      assert {:error, "Invalid date value: []"} = Builder.build_date([], [])
    end
  end

  describe "build_datetime/2" do
    test "returns the datetime value" do
      assert {:ok, ~U[2023-10-01 12:34:56Z]} =
               Builder.build_datetime(~U[2023-10-01 12:34:56Z], [])

      assert {:ok, ~U[2023-10-01 12:34:56Z]} = Builder.build_datetime("2023-10-01T12:34:56Z", [])

      assert {:ok, ~U[2023-10-01 01:00:00Z]} =
               Builder.build_datetime("2023-10-01T10:00:00+09:00", [])
    end

    test "returns error for non-datetime value" do
      assert {:error, "Given value is not ISO8601 format: \"2023-10-01T12:34:56\""} =
               Builder.build_datetime("2023-10-01T12:34:56", [])

      assert {:error, "Invalid datetime value: []"} = Builder.build_datetime([], [])
    end
  end
end
