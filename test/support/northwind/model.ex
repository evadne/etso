defmodule Northwind.Model do
  defmacro __using__(_) do
    parent = __MODULE__

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias unquote(parent)
    end
  end
end
