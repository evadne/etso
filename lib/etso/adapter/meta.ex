defmodule Etso.Adapter.Meta do
  @moduledoc false

  @type t :: %__MODULE__{repo: Ecto.Repo.t()}
  @enforce_keys ~w(repo)a
  defstruct repo: nil
end
