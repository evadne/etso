defmodule Etso.Adapter.TableSupervisor do
  @moduledoc """
  Provides convenience functions to spin up a Dynamic Supervisor
  """

  def child_spec([repo]) do
    DynamicSupervisor.child_spec(strategy: :one_for_one, name: name(repo))
  end

  def name(repo) do
    Module.concat([repo, TableSupervisor])
  end
end
