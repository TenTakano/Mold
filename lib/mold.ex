defmodule Mold do
  defmacro __using__(_opts) do
    quote do
      import Mold
      Module.register_attribute(__MODULE__, :slots, accumulate: true)
      Module.register_attribute(__MODULE__, :struct_slot, accumulate: true)
      Module.register_attribute(__MODULE__, :required_slot, accumulate: true)
      @before_compile Mold
    end
  end

  def defschema(do: block) do
    quote do
      unquote(block)
    end
  end

  defmacro req(name, type, opts \\ []) do
    quote do
      @slots {unquote(name), unquote(type), unquote(opts)}
      @struct_slot unquote(name)
      @required_slot unquote(name)
    end
  end

  defmacro opt(name, type, opts \\ []) do
    quote do
      @slots {unquote(name), unquote(type), unquote(opts)}
      @struct_slot unquote(name)
    end
  end

  defmacro __before_compile__(env) do
    slots = Module.get_attribute(env.module, :slots) || []
    struct_slot = Module.get_attribute(env.module, :struct_slot) || []
    required_slot = Module.get_attribute(env.module, :required_slot) || []

    quote do
      @enforce_keys unquote(required_slot)
      defstruct unquote(struct_slot)

      defp __slots__, do: unquote(Macro.escape(slots))
      defp __struct_slot__, do: unquote(Macro.escape(struct_slot))

      def new(params) do
        unquote(required_slot)
        |> Enum.reject(&Map.has_key?(params, &1))
        |> case do
          [] ->
            {:ok, struct(__MODULE__, params)}

          missing_keys ->
            {:error,
             %{
               error: "Missing required keys",
               missing_keys: missing_keys,
               available_keys: __struct_slot__()
             }}
        end
      end
    end
  end
end
