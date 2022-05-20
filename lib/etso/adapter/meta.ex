defmodule Etso.Adapter.Meta do
  @moduledoc false

  @type t :: %__MODULE__{
          repo: Ecto.Repo.t(),
          cache: :ets.tab() | nil,
          pid: pid() | nil,
          stacktrace: true | false
        }

  @enforce_keys ~w(repo)a
  defstruct repo: nil, cache: nil, pid: nil, stacktrace: false

  @behaviour Access
  defdelegate get(v, key, default), to: Map
  defdelegate fetch(v, key), to: Map
  defdelegate get_and_update(v, key, func), to: Map
  defdelegate pop(v, key), to: Map
end
