defmodule Etso.Adapter.TableServer do
  @moduledoc """
  The Table Server is a simple GenServer tasked with starting and holding an ETS table, which is
  namespaced in the Table Registry by the Repo and the Schema. Once the Table Server starts, it
  will attempt to create the ETS table, and also register the ETS table with the Table Registry.
  """

  use GenServer
  alias Etso.Adapter.TableRegistry

  @spec start_link({Etso.repo(), Etso.schema(), atom()}) :: GenServer.on_start()

  @doc """
  Starts the Table Server for the given `repo` and `schema`, with registration under `name`.
  """
  def start_link({repo, schema, name}) do
    GenServer.start_link(__MODULE__, {repo, schema}, name: name)
  end

  @impl GenServer
  def init({repo, schema}) do
    table_name = Module.concat([repo, schema])
    table_reference = :ets.new(table_name, [:set, :public])
    repo_metadata = Ecto.Adapter.lookup_meta(repo)

    optional_dets_reference =
      if repo_metadata.persist_to_dets do
        start_from_dets(table_name, table_reference, repo_metadata.dets_folder)
      end

    Process.flag(:trap_exit, true)

    case TableRegistry.register_table(repo, schema, table_reference) do
      :ok -> {:ok, {table_reference, optional_dets_reference}}
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl GenServer
  def terminate(_reason, {table_reference, dets_reference}) do
    if dets_reference, do: :ets.to_dets(table_reference, dets_reference)
  end

  defp start_from_dets(table_name, ets_table_reference, dets_folder) do
    file =
      [dets_folder, table_name]
      |> Enum.map(&to_string/1)
      |> Path.join()
      |> String.to_atom()

    {:ok, dets_reference} = :dets.open_file(table_name, type: :set, file: file)
    :dets.to_ets(dets_reference, ets_table_reference)
    dets_reference
  end
end
