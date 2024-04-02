defmodule Etso.Adapter.Supervisor do
  @moduledoc """
  Repo-level Supervisor which supports the ETS Adapter. Within the Supervision Tree, a Dynamic
  Supervisor is used to hold the Table Servers, and a Registry is used to keep track of both the
  Table Servers, and their ETS Tables.
  """

  use Supervisor
  @spec start_link(Etso.repo()) :: Supervisor.on_start()

  @doc """
  Starts the Supervisor for the given `repo`.
  """
  def start_link(repo) do
    Supervisor.start_link(__MODULE__, repo)
  end

  @impl Supervisor
  def init(repo) do
    children = [
      {Etso.Adapter.TableRegistry, repo},
      {Etso.Adapter.TableSupervisor, repo}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
