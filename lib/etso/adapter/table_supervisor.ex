defmodule Etso.Adapter.TableSupervisor do
  @moduledoc """
  Provides convenience function to spin up a Dynamic Supervisor, which is used to hold the Table
  Servers.
  """

  @spec child_spec(Etso.repo()) :: Supervisor.child_spec()
  @spec start_child(Etso.repo(), {module(), term()}) :: DynamicSupervisor.on_start_child()

  @doc """
  Returns Child Specification for the Table Supervisor that will be associated with the `repo`.
  """
  def child_spec(repo) do
    DynamicSupervisor.child_spec(strategy: :one_for_one, name: build_name(repo))
  end

  @doc """
  Starts the Child under the Table Supervisor associated with the `repo`.
  """
  def start_child(repo, child_spec) do
    DynamicSupervisor.start_child(build_name(repo), child_spec)
  end

  defp build_name(repo) do
    Module.concat([repo, Enum.at(Module.split(__MODULE__), -1)])
  end
end
