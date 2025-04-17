defmodule Mold.Builder do
  def build(schema, params) when is_list(schema) and is_map(params) do
    Enum.reduce(schema, {%{}, []}, fn {key, type, opts}, {acc, errors} ->
      with {:ok, value} <- get_value(params, key, opts) do
        {Map.put(acc, key, build(type, value, opts)), errors}
      else
        error ->
          {acc, [error | errors]}
      end
    end)
    |> case do
      {result, []} ->
        {:ok, result}

      {_, errors} ->
        {:error, Enum.reverse(errors)}
    end
  end

  def get_value(params, key, opts) do
    case {Map.fetch(params, key), opts[:required], opts[:default]} do
      {{:ok, nil}, true, _} -> {:error, "Missing required key :#{key}"}
      {{:ok, value}, _, _} -> {:ok, value}
      {:error, true, _} -> {:error, "Missing required key :#{key}"}
      {:error, _, value} -> {:ok, value}
    end
  end

  def build(:string, value, opts), do: build_string(value, opts)
  def build(:integer, value, opts), do: build_integer(value, opts)
  def build(:float, value, opts), do: build_float(value, opts)
  def build(:boolean, value, opts), do: build_boolean(value, opts)
  def build(:atom, value, opts), do: build_atom(value, opts)

  def build_string(value, _opts) when is_binary(value), do: {:ok, value}
  def build_string(value, _opts) when is_integer(value), do: {:ok, Integer.to_string(value)}
  def build_string(value, _opts) when is_float(value), do: {:ok, Float.to_string(value)}
  def build_string(_value, _opts), do: {:error, "Invalid string value"}

  def build_integer(value, _opts) when is_integer(value), do: {:ok, value}

  def build_integer(value, _opts) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> {:ok, int}
      _ -> {:error, "Invalid integer value"}
    end
  end

  def build_integer(_value, _opts), do: {:error, "Invalid integer value"}

  def build_float(value, _opts) when is_float(value), do: {:ok, value}

  def build_float(value, _opts) when is_binary(value) do
    case Float.parse(value) do
      {float, ""} -> {:ok, float}
      _ -> {:error, "Invalid float value"}
    end
  end

  def build_float(_value, _opts), do: {:error, "Invalid float value"}

  def build_boolean(value, _opts) when is_boolean(value), do: {:ok, value}

  def build_boolean(value, _opts) when is_binary(value) do
    case String.downcase(value) do
      "true" -> {:ok, true}
      "false" -> {:ok, false}
      _ -> {:error, "Invalid boolean value"}
    end
  end

  def build_boolean(_value, _opts), do: {:error, "Invalid boolean value"}

  def build_atom(value, _opts) when is_atom(value), do: {:ok, value}
  def build_atom(_value, _opts), do: {:error, "Invalid atom value"}
end
