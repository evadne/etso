defmodule Etso.Adapter.Meta do
  defstruct repo: nil, meta_table_name: nil

  @type t :: %__MODULE__{
          repo: module(),
          meta_table_name: term()
        }
end
