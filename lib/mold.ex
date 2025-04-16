defmodule Mold do
  defmacro __using__(_opts) do
    quote do
      import Mold
      Module.register_attribute(__MODULE__, :struct_field, accumulate: true)
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      @before_compile Mold
    end
  end

  def defschema(do: block) do
    quote do
      unquote(block)
    end
  end

  defmacro field(name, type, opts \\ []) do
    quote do
      @struct_field unquote(name)
      @fields {unquote(name), unquote(type), unquote(opts)}
    end
  end

  defmacro __before_compile__(env) do
    struct_field = Module.get_attribute(env.module, :struct_field) || []
    fields = Module.get_attribute(env.module, :fields) || []

    quote do
      defstruct unquote(struct_field)

      defp __fields__, do: unquote(Macro.escape(fields))

      def new(params \\ %{}), do: struct(__MODULE__, params)
    end
  end
end
