defmodule Etso.Adapter.Supervisor do
  @moduledoc """
  Repo-level Supervisor which supports the ETS Adapter. Within the Supervision Tree, a Dynamic
  Supervisor is used to hold the Table Servers. All Table Servers register themselves, alongside
  the reference to the ETS table held inside, with the global Registry (named `Etso.Registry`).
  """

  use Supervisor
  alias Etso.Adapter.Meta
  alias Etso.Adapter.TableSupervisor

  @spec start_link(Etso.adapter_meta()) :: Supervisor.on_start()

  @doc """
  Starts the Supervisor for the given `repo`.
  """
  def start_link(%Meta{} = adapter_meta) do
    Supervisor.start_link(__MODULE__, adapter_meta)
  end

  @impl Supervisor
  def init(%Meta{} = adapter_meta) do
    children = [{TableSupervisor, adapter_meta}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
