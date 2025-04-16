defmodule Sample do
  use Mold

  defschema do
    field(:name, :string)
    field(:age, :integer)
    field(:active, :boolean)
  end
end

defmodule MoldTest do
  use ExUnit.Case, async: true
  doctest Mold

  test "Mold.new/1 creates a new struct with default values" do
    assert %Sample{name: nil, age: nil, active: nil} = Sample.new()

    assert %Sample{name: "name", age: 25, active: true} =
             Sample.new(%{name: "name", age: 25, active: true})
  end
end
