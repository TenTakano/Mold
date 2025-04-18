# Mold

## Overview

Lightweight library for performing schema validation in Elixir. This library utilizes a macro to define schemas, which are then used to validate input maps. If the map adheres to the schema, it is automatically converted into a struct. Additionally, if implicit type conversion is feasible during validation, the appropriate conversions will be applied.

## Usage Example

Defining the schema as shown below produces a struct. The keys in the input map are automatically converted, whether they are strings or atoms.

```elixir
defmodule Sample do
  use Mold

  defschema do
    req :name, :string
    req :age, :integer
    req :active, :boolean
    opt :note, :string
  end
end

iex> Sample.new(%{"name" => "Alice", "age" => "30", "active" => true})
{:ok, %Sample{name: "Alice", age: 30, active: true, note: nil}}
```

If the input map does not conform to the schema, an error is returned. The error message indicates the specific field that failed validation and the reason for the failure.

```elixir
iex> Sample.new(%{"name" => "Bob", "age" => "invalid", "active" => true})
{:error, %Mold.Error{message: "Invalid value for :age. Expected an integer, got: \"invalid\"."}}
```
