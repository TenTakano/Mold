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

  test "Mold.new/1 creates a new struct with default values" do
    assert {:ok, %Sample{name: "name", age: 25, active: true, note: nil}} =
             Sample.new(%{name: "name", age: 25, active: true})

    assert {:ok, %Sample{name: "name", age: 25, active: true, note: "note"}} =
             Sample.new(%{name: "name", age: 25, active: true, note: "note"})
  end

  test "Mold.new/1 returns error for missing required keys" do
    assert {:error, errors} = Sample.new(%{name: "name", age: "not an integer"})

    assert errors == [
             age: "Invalid integer value: \"not an integer\"",
             active: "Missing required key"
           ]
  end
end
