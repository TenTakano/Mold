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

      assert Builder.build(schema, params) ==
               {:error, [age: "Missing required key"]}
    end

    test "returns error for invalid values" do
      schema = [
        {:age, :integer, required: true}
      ]

      params = %{age: "not an integer"}

      assert Builder.build(schema, params) ==
               {:error, [age: "Invalid integer value: \"not an integer\""]}
    end

    test "returns multiple errors" do
      schema = [
        {:age, :integer, required: true},
        {:name, :string, required: true}
      ]

      params = %{name: nil, age: "not an integer"}

      assert Builder.build(schema, params) ==
               {:error,
                [
                  name: "Missing required key",
                  age: "Invalid integer value: \"not an integer\""
                ]}
    end
  end

  describe "get_value/3" do
    test "returns value of existing key" do
      assert Builder.get_value(%{key: "value"}, :key, required: true) ==
               {:ok, "value"}

      assert Builder.get_value(%{key: "value"}, :key, required: false) ==
               {:ok, "value"}
    end

    test "returns default value for missing key" do
      assert Builder.get_value(%{}, :key, default: "default") ==
               {:ok, "default"}
    end

    test "returns nil for missing key with no default if not required" do
      assert Builder.get_value(%{}, :key, required: false) ==
               {:ok, nil}
    end

    test "returns error for missing required key" do
      assert Builder.get_value(%{}, :key, required: true) ==
               {:error, "Missing required key"}
    end

    test "returns error for nil value if required" do
      assert Builder.get_value(%{key: nil}, :key, required: true) ==
               {:error, "Missing required key"}
    end
  end

  describe "build_string/2" do
    test "converts value to string" do
      assert Builder.build_string("test", []) == {:ok, "test"}
      assert Builder.build_string(123, []) == {:ok, "123"}
      assert Builder.build_string(123.45, []) == {:ok, "123.45"}
    end

    test "returns error for invalid value" do
      assert Builder.build_string(nil, []) ==
               {:error, "Invalid string value: nil"}

      assert Builder.build_string([], []) ==
               {:error, "Invalid string value: []"}
    end
  end

  describe "build_integer/2" do
    test "converts value to integer" do
      assert Builder.build_integer(123, []) == {:ok, 123}
      assert Builder.build_integer("123", []) == {:ok, 123}
    end

    test "returns error for invalid value" do
      assert Builder.build_integer(123.45, []) ==
               {:error, "Invalid integer value: 123.45"}

      assert Builder.build_integer(nil, []) ==
               {:error, "Invalid integer value: nil"}

      assert Builder.build_integer([], []) ==
               {:error, "Invalid integer value: []"}

      assert Builder.build_integer("abc", []) ==
               {:error, "Invalid integer value: \"abc\""}
    end
  end

  describe "build_float/2" do
    test "converts value to float" do
      assert Builder.build_float(123.45, []) == {:ok, 123.45}
      assert Builder.build_float("123.45", []) == {:ok, 123.45}
    end

    test "returns error for invalid value" do
      assert Builder.build_float(123, []) ==
               {:error, "Invalid float value: 123"}

      assert Builder.build_float(nil, []) ==
               {:error, "Invalid float value: nil"}

      assert Builder.build_float([], []) ==
               {:error, "Invalid float value: []"}

      assert Builder.build_float("abc", []) ==
               {:error, "Invalid float value: \"abc\""}
    end
  end

  describe "build_boolean/2" do
    test "converts value to boolean" do
      assert Builder.build_boolean(true, []) == {:ok, true}
      assert Builder.build_boolean(false, []) == {:ok, false}
      assert Builder.build_boolean("true", []) == {:ok, true}
      assert Builder.build_boolean("false", []) == {:ok, false}
    end

    test "returns error for invalid value" do
      assert Builder.build_boolean(nil, []) ==
               {:error, "Invalid boolean value: nil"}

      assert Builder.build_boolean([], []) ==
               {:error, "Invalid boolean value: []"}

      assert Builder.build_boolean("abc", []) ==
               {:error, "Invalid boolean value: \"abc\""}
    end
  end

  describe "build_atom/2" do
    test "returns the atom value" do
      assert Builder.build_atom(:test, []) == {:ok, :test}
    end

    test "returns error for non-atom value" do
      assert Builder.build_atom([], []) ==
               {:error, "Invalid atom value: []"}

      assert Builder.build_atom("abc", []) ==
               {:error, "Invalid atom value: \"abc\""}
    end
  end

  describe "build_time/2" do
    test "returns the time value" do
      assert Builder.build_time(~T[12:34:56], []) ==
               {:ok, ~T[12:34:56]}

      assert Builder.build_time("12:34:56", []) ==
               {:ok, ~T[12:34:56]}

      assert Builder.build_time(~U[2023-10-01 12:34:56Z], []) ==
               {:ok, ~T[12:34:56]}
    end

    test "returns error for non-time value" do
      assert Builder.build_time("45:67:89", []) ==
               {:error, "Given value is not ISO8601 format: \"45:67:89\""}

      assert Builder.build_time([], []) ==
               {:error, "Invalid time value: []"}
    end
  end

  describe "build_date/2" do
    test "returns the date value" do
      assert Builder.build_date(~D[2023-10-01], []) ==
               {:ok, ~D[2023-10-01]}

      assert Builder.build_date("2023-10-01", []) ==
               {:ok, ~D[2023-10-01]}

      assert Builder.build_date(~U[2023-10-01 12:34:56Z], []) ==
               {:ok, ~D[2023-10-01]}
    end

    test "returns error for non-date value" do
      assert Builder.build_date("2023-10-32", []) ==
               {:error, "Given value is not ISO8601 format: \"2023-10-32\""}

      assert Builder.build_date([], []) ==
               {:error, "Invalid date value: []"}
    end
  end

  describe "build_datetime/2" do
    test "returns the datetime value" do
      assert Builder.build_datetime(~U[2023-10-01 12:34:56Z], []) ==
               {:ok, ~U[2023-10-01 12:34:56Z]}

      assert Builder.build_datetime("2023-10-01T12:34:56Z", []) ==
               {:ok, ~U[2023-10-01 12:34:56Z]}

      assert Builder.build_datetime("2023-10-01T10:00:00+09:00", []) ==
               {:ok, ~U[2023-10-01 01:00:00Z]}
    end

    test "returns error for non-datetime value" do
      assert Builder.build_datetime("2023-10-01T12:34:56", []) ==
               {:error, "Given value is not ISO8601 format: \"2023-10-01T12:34:56\""}

      assert Builder.build_datetime([], []) ==
               {:error, "Invalid datetime value: []"}
    end
  end
end
