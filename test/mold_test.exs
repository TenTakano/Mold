defmodule Sample do
  use Mold

  defschema do
    req :name, :string
    req :age, :integer
    req :active, :boolean
    opt :note, :string
  end
end

defmodule MoldTest do
  use ExUnit.Case, async: true
  doctest Mold

  describe "struct" do
    test "has Access protocol with @derive" do
      sample = %Sample{name: "name", age: 25, active: true}
      assert sample[:name] == "name"
      assert sample[:age] == 25
      assert sample[:active] == true
      assert sample[:note] == nil
    end
  end

  describe "new/1" do
    test "new/1 creates a new struct with default values" do
      assert {:ok, %Sample{name: "name", age: 25, active: true, note: nil}} =
               Sample.new(%{name: "name", age: 25, active: true})

      assert {:ok, %Sample{name: "name", age: 25, active: true, note: "note"}} =
               Sample.new(%{name: "name", age: 25, active: true, note: "note"})
    end

    test "new/1 creates a new struct with converting key to atom" do
      assert {:ok, %Sample{name: "name", age: 25, active: true, note: nil}} =
               Sample.new(%{"name" => "name", "age" => 25, "active" => true})

      assert {:ok, %Sample{name: "name", age: 25, active: true, note: "note"}} =
               Sample.new(%{"name" => "name", "age" => 25, "active" => true, "note" => "note"})
    end

    test "new/1 returns error for missing required keys" do
      assert {:error, errors} = Sample.new(%{name: "name", age: "not an integer"})

      assert errors == [
               age: "Invalid integer value: \"not an integer\"",
               active: "Missing required key"
             ]
    end
  end

  describe "new!/1" do
    test "new!/1 creates a new struct with default values" do
      assert %Sample{name: "name", age: 25, active: true, note: nil} =
               Sample.new!(%{name: "name", age: 25, active: true})

      assert %Sample{name: "name", age: 25, active: true, note: "note"} =
               Sample.new!(%{name: "name", age: 25, active: true, note: "note"})
    end

    test "new!/1 raises an error for missing required keys" do
      assert_raise ArgumentError, fn ->
        Sample.new!(%{name: "name", age: "not an integer"})
      end
    end
  end
end
