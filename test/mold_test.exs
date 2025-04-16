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
    assert {:error, error} = Sample.new(%{name: "name", age: 25})
    assert error.error == "Missing required keys"
    assert error.missing_keys == [:active]
    assert_elements_equal(error.available_keys, [:name, :age, :active, :note])
  end

  defp assert_elements_equal(list1, list2) do
    assert Enum.sort(list1) == Enum.sort(list2)
  end
end
