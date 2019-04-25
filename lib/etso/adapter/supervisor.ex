defmodule Etso.Adapter.Supervisor do
  @moduledoc """
  Supervision tree which supports the ETS Adapter. There are several
  children used in the tree:

  - a Dynamic Supervisor to hold the Table Servers
  - a Registry to keep track of the Table Servers
  """

  use Supervisor

  def start_link(repo) do
    Supervisor.start_link(__MODULE__, repo, name: __MODULE__)
  end

  @impl true
  def init(repo) do
    children = [
      {Etso.Adapter.TableSupervisor, [repo]},
      {Etso.Adapter.TableRegistry, [repo]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
