defmodule Etso.Adapter do
  @moduledoc """
  Used as an Adapter in Repo modules, which transparently spins up one ETS table for
  each Schema used with the Repo, namespaced to the Repo to allow concurrent running
  of multiple Repositories.
  """

  @behaviour Ecto.Adapter

  defmacro __before_compile__(_opts), do: :ok
  def ensure_all_started(_config, _type), do: {:ok, []}

  def init(config) do
    {:ok, repo} = Keyword.fetch(config, :repo)
    child_spec = __MODULE__.Supervisor.child_spec(repo)
    adapter_meta = %{repo: repo}
    {:ok, child_spec, adapter_meta}
  end

  def checkout(_, _, fun), do: fun.()

  def loaders(:binary_id, type), do: [Ecto.UUID, type]
  def loaders(:embed_id, type), do: [Ecto.UUID, type]
  def loaders(_, type), do: [type]

  def dumpers(:binary_id, type), do: [type, Ecto.UUID]
  def dumpers(:embed_id, type), do: [type, Ecto.UUID]
  def dumpers(_, type), do: [type]

  defp get_table(adapter_meta, schema) do
    __MODULE__.TableRegistry.get_table(adapter_meta.repo, schema)
  end

  use __MODULE__.Behaviour.Schema
  use __MODULE__.Behaviour.Queryable
end
