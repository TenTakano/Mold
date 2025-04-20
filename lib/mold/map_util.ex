defmodule Mold.MapUtil do
  def to_atom_keys(map) do
    Map.new(map, fn
      {key, value} when is_atom(key) -> {key, value}
      {key, value} when is_binary(key) -> {String.to_existing_atom(key), value}
      {key, _value} -> raise ArgumentError, "Invalid key type: #{inspect(key)}"
    end)
  end
end
