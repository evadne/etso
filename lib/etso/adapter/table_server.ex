defmodule Etso.Adapter.TableServer do
  @moduledoc """
  The Table Server is a simple GenServer tasked with starting and holding an ETS table, which is
  namespaced in Etso.Registry by the Repo, the unique reference (to support dynamic Repos), and
  the Schema. Once the Table Server starts, it will attempt to create the ETS table, and also
  register the ETS table with Etso.Registry.
  """

  use GenServer

  @spec start_link({Etso.adapter_meta(), Etso.schema()}) :: GenServer.on_start()
  @spec init({Etso.adapter_meta(), Etso.schema()}) :: {:ok, Etso.table()} | {:stop, term()}

  @doc """
  Starts the Table Server for the given `repo` and `schema`, with registration under `name`.
  """
  def start_link({%Etso.Adapter.Meta{} = meta, schema}) do
    GenServer.start_link(__MODULE__, {meta, schema}, name: build_name(meta, schema))
  end

  @impl GenServer
  def init({%Etso.Adapter.Meta{} = meta, schema}) do
    table_reference = :ets.new(schema, [:set, :public])

    case Etso.Registry.register(meta, schema, table_reference) do
      :ok -> {:ok, table_reference}
      {:error, reason} -> {:stop, reason}
    end
  end

  defp build_name(%Etso.Adapter.Meta{} = meta, schema) do
    {:via, Etso.Registry, {meta.repo, meta.reference, schema, __MODULE__}}
  end
end
