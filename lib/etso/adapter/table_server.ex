defmodule Etso.Adapter.TableServer do
  use GenServer
  import Etso.Adapter.TableRegistry, only: [register_table: 3]

  def start_link({repo, schema, server_name}) do
    GenServer.start_link(__MODULE__, {repo, schema}, name: server_name)
  end

  def init({repo, schema}) do
    {:ok, table_reference} = build_table(repo, schema)
    {:ok, _} = register_table(repo, schema, table_reference)
    {:ok, table_reference}
  end

  defp build_table(repo, schema) do
    table_name = Module.concat([repo, schema])
    {:ok, :ets.new(table_name, [:set, :public])}
  end
end
