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
    opts = Keyword.put(opts, :required, true)

    quote do
      @slots {unquote(name), unquote(type), unquote(opts)}
      @struct_slot unquote(name)
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

      @behaviour Access

      @impl Access
      def fetch(struct, key), do: Map.fetch(struct, key)

      @impl Access
      def get_and_update(struct, key, fun), do: Map.get_and_update(struct, key, fun)

      @impl Access
      def pop(struct, key), do: Map.pop(struct, key)

      defp __slots__, do: unquote(Macro.escape(slots))

      def new(params) do
        atom_keys_params = Mold.MapUtil.to_atom_keys(params)

        Mold.Builder.build(__slots__(), atom_keys_params)
        |> case do
          {:ok, result} ->
            {:ok, struct(__MODULE__, result)}

          {:error, _} = error ->
            error
        end
      end

      def new!(params) do
        case new(params) do
          {:ok, result} ->
            result

          {:error, errors} ->
            raise ArgumentError, message: "Invalid parameters: #{inspect(errors)}"
        end
      end
    end
  end
end
