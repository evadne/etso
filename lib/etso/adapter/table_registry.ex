defmodule Etso.Adapter.TableRegistry do
  @moduledoc """
  Provides convenience functions used by the Table Server to register their ETS tables,
  and by the Adapter itself to get the ETS tables.
  """

  def child_spec([repo]) do
    Registry.child_spec(keys: :unique, name: name(repo))
  end

  def name(repo) do
    Module.concat([repo, TableRegistry])
  end

  def get_table(repo, schema) do
    lookup_table(repo, schema) || start_table(repo, schema)
  end

  def register_table(repo, schema, table_reference) do
    Registry.register(name(repo), {schema, :ets_table}, table_reference)
  end

  defp lookup_table(repo, schema) do
    case Registry.lookup(name(repo), {schema, :ets_table}) do
      [{_, table_reference}] -> table_reference
      [] -> nil
    end
  end

  defp start_table(repo, schema) do
    {:ok, _} = ensure_server_started(repo, schema)
    lookup_table(repo, schema)
  end

  defp ensure_server_started(repo, schema) do
    case start_server(repo, schema) do
      {:ok, pid} -> {:ok, pid}
      {:ok, pid, _} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      _ -> :error
    end
  end

  defp start_server(repo, schema) do
    server_module = Etso.Adapter.TableServer
    server_name = {:via, Registry, {name(repo), schema}}
    server_arguments = {repo, schema, server_name}

    repo
    |> Etso.Adapter.TableSupervisor.name()
    |> DynamicSupervisor.start_child({server_module, server_arguments})
  end
end
