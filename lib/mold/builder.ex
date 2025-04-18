defmodule Mold.Builder do
  def build(schema, params) when is_list(schema) and is_map(params) do
    Enum.reduce(schema, {%{}, []}, fn {key, type, opts}, {acc, errors} ->
      with {:ok, original_value} <- get_value(params, key, opts),
           {:ok, value} <- build_value(type, original_value, opts) do
        {Map.put(acc, key, value), errors}
      else
        {:error, error} ->
          {acc, [{key, error} | errors]}
      end
    end)
    |> case do
      {result, []} ->
        {:ok, result}

      {_, errors} ->
        {:error, errors}
    end
  end

  def get_value(params, key, opts) do
    case {Map.fetch(params, key), opts[:required], opts[:default]} do
      {{:ok, nil}, true, _} -> {:error, "Missing required key"}
      {{:ok, value}, _, _} -> {:ok, value}
      {:error, true, _} -> {:error, "Missing required key"}
      {:error, _, value} -> {:ok, value}
    end
  end

  defp build_value(_, nil, _opts), do: {:ok, nil}
  defp build_value(:string, value, opts), do: build_string(value, opts)
  defp build_value(:integer, value, opts), do: build_integer(value, opts)
  defp build_value(:float, value, opts), do: build_float(value, opts)
  defp build_value(:boolean, value, opts), do: build_boolean(value, opts)
  defp build_value(:atom, value, opts), do: build_atom(value, opts)
  defp build_value(:time, value, opts), do: build_time(value, opts)
  defp build_value(:date, value, opts), do: build_date(value, opts)
  defp build_value(:datetime, value, opts), do: build_datetime(value, opts)

  # Built-in types

  def build_string(value, _opts) when is_binary(value), do: {:ok, value}
  def build_string(value, _opts) when is_integer(value), do: {:ok, Integer.to_string(value)}
  def build_string(value, _opts) when is_float(value), do: {:ok, Float.to_string(value)}
  def build_string(value, _opts), do: {:error, "Invalid string value: #{inspect(value)}"}

  def build_integer(value, _opts) when is_integer(value), do: {:ok, value}

  def build_integer(value, _opts) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> {:ok, int}
      _ -> {:error, "Invalid integer value: #{inspect(value)}"}
    end
  end

  def build_integer(value, _opts), do: {:error, "Invalid integer value: #{inspect(value)}"}

  def build_float(value, _opts) when is_float(value), do: {:ok, value}

  def build_float(value, _opts) when is_binary(value) do
    case Float.parse(value) do
      {float, ""} -> {:ok, float}
      _ -> {:error, "Invalid float value: #{inspect(value)}"}
    end
  end

  def build_float(value, _opts), do: {:error, "Invalid float value: #{inspect(value)}"}

  def build_boolean(value, _opts) when is_boolean(value), do: {:ok, value}

  def build_boolean(value, _opts) when is_binary(value) do
    case String.downcase(value) do
      "true" -> {:ok, true}
      "false" -> {:ok, false}
      _ -> {:error, "Invalid boolean value: #{inspect(value)}"}
    end
  end

  def build_boolean(value, _opts), do: {:error, "Invalid boolean value: #{inspect(value)}"}

  def build_atom(value, _opts) when is_atom(value), do: {:ok, value}
  def build_atom(value, _opts), do: {:error, "Invalid atom value: #{inspect(value)}"}

  # Custom types

  def build_time(%Time{} = value, _opts), do: {:ok, value}
  def build_time(%DateTime{} = value, _opts), do: {:ok, DateTime.to_time(value)}

  def build_time(value, _opts) when is_binary(value) do
    case Time.from_iso8601(value) do
      {:ok, time} -> {:ok, time}
      {:error, _} -> {:error, "Given value is not ISO8601 format: #{inspect(value)}"}
    end
  end

  def build_time(value, _opts), do: {:error, "Invalid time value: #{inspect(value)}"}

  def build_date(%Date{} = value, _opts), do: {:ok, value}
  def build_date(%DateTime{} = value, _opts), do: {:ok, DateTime.to_date(value)}

  def build_date(value, _opts) when is_binary(value) do
    case Date.from_iso8601(value) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, "Given value is not ISO8601 format: #{inspect(value)}"}
    end
  end

  def build_date(value, _opts), do: {:error, "Invalid date value: #{inspect(value)}"}

  def build_datetime(%DateTime{} = value, _opts), do: {:ok, value}

  def build_datetime(value, _opts) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _} -> {:ok, datetime}
      {:error, _} -> {:error, "Given value is not ISO8601 format: #{inspect(value)}"}
    end
  end

  def build_datetime(value, _opts), do: {:error, "Invalid datetime value: #{inspect(value)}"}
end
