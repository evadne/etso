defmodule Etso.Adapter.Meta do
  @moduledoc """
  Represents the runtime metadata held by the adapter when the underlying Repo has been started.
  """

  @type t :: %__MODULE__{
          repo: Ecto.Repo.t(),
          reference: reference(),
          cache: :ets.tab() | nil,
          pid: pid() | nil,
          stacktrace: true | false
        }

  @enforce_keys ~w(repo reference)a
  defstruct repo: nil, reference: nil, cache: nil, pid: nil, stacktrace: false

  @behaviour Access
  defdelegate get(v, key, default), to: Map
  defdelegate fetch(v, key), to: Map
  defdelegate get_and_update(v, key, func), to: Map
  defdelegate pop(v, key), to: Map
end
