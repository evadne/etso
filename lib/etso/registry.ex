defmodule Etso.Registry do
  @moduledoc """
  Provides convenience function to interact with the global Registry (named `Etso.Registry`),
  which is used to hold the Table Servers (registered by GenServer when starting up), alongside
  their ETS tables (registered when the Table Server starts).
  """

  @spec ensure(Etso.adapter_meta(), Etso.schema()) :: {:ok, Etso.table()} | {:error, term()}
  @spec register(Etso.adapter_meta(), Etso.schema(), Etso.table()) :: :ok | {:error, term()}

  alias Etso.Adapter.Meta
  alias Etso.Adapter.TableServer
  alias Etso.Adapter.TableSupervisor

  @doc """
  Returns the ETS table associated with the given `repo` which is used to hold data for `schema`.
  If the table does not exist, starts the table in-situ and returns it.
  """
  def ensure(%Meta{} = adapter_meta, schema) do
    case lookup(adapter_meta, schema) do
      {:ok, table_reference} -> {:ok, table_reference}
      {:error, :not_found} -> start(adapter_meta, schema)
    end
  end

  @doc """
  Registers the ETS table associated with the given `repo` which is used to hold data for `schema`.
  """
  def register(%Meta{} = adapter_meta, schema, table_reference) do
    with key = build_key(adapter_meta, schema),
         {:ok, _} <- Registry.register(__MODULE__, key, table_reference) do
      :ok
    end
  end

  defp lookup(%Meta{} = adapter_meta, schema) do
    with key = build_key(adapter_meta, schema) do
      case Registry.lookup(__MODULE__, key) do
        [{_pid, table_reference}] -> {:ok, table_reference}
        [] -> {:error, :not_found}
      end
    end
  end

  defp start(%Meta{} = adapter_meta, schema) do
    with {:ok, _} <- ensure_server_started(adapter_meta, schema) do
      lookup(adapter_meta, schema)
    end
  end

  defp ensure_server_started(%Meta{} = adapter_meta, schema) do
    case start_server(%Meta{} = adapter_meta, schema) do
      {:ok, pid} -> {:ok, pid}
      {:ok, pid, _} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  defp start_server(%Meta{} = adapter_meta, schema) do
    child_spec = {TableServer, {adapter_meta, schema}}
    TableSupervisor.start_child(adapter_meta, child_spec)
  end

  defp build_key(%Meta{} = adapter_meta, schema) do
    {adapter_meta.repo, adapter_meta.reference, schema, :ets_table}
  end

  @doc false
  def register_name({key, value}, pid), do: Registry.register_name({__MODULE__, key, value}, pid)
  def register_name(key, pid), do: Registry.register_name({__MODULE__, key}, pid)

  @doc false
  def unregister_name(key), do: Registry.unregister(__MODULE__, key)

  @doc false
  def whereis_name({key, _value}), do: Registry.whereis_name({__MODULE__, key})
  def whereis_name(key), do: Registry.whereis_name({__MODULE__, key})

  @doc false
  def send(key, message), do: Registry.send({__MODULE__, key}, message)
end
