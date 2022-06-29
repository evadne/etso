defmodule Etso.Adapter.TableSupervisor do
  @moduledoc """
  Provides convenience function to spin up a Dynamic Supervisor, which is used to hold the Table
  Servers.
  """

  alias Etso.Adapter.Meta

  @spec child_spec(Etso.adapter_meta()) :: Supervisor.child_spec()
  @spec start_child(Etso.adapter_meta(), {module(), term()}) :: DynamicSupervisor.on_start_child()

  @doc """
  Returns Child Specification for the Table Supervisor that will be associated with the `repo`.
  """
  def child_spec(%Meta{} = adapter_meta) do
    DynamicSupervisor.child_spec(strategy: :one_for_one, name: build_name(adapter_meta))
  end

  @doc """
  Starts the Child under the Table Supervisor associated with the `repo`.
  """
  def start_child(%Meta{} = adapter_meta, child_spec) do
    DynamicSupervisor.start_child(build_name(adapter_meta), child_spec)
  end

  defp build_name(%Meta{} = adapter_meta) do
    {:via, Etso.Registry, {adapter_meta.repo, adapter_meta.reference, __MODULE__}}
  end
end
