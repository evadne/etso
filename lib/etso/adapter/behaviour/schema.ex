defmodule Etso.Adapter.Behaviour.Schema do
  @moduledoc false
  @behaviour Ecto.Adapter.Schema

  alias Etso.Adapter.TableRegistry
  alias Etso.ETS.TableStructure

  @impl Ecto.Adapter.Schema
  def autogenerate(:id), do: :erlang.unique_integer()
  def autogenerate(:binary_id), do: Ecto.UUID.bingenerate()
  def autogenerate(:embed_id), do: Ecto.UUID.bingenerate()

  @impl Ecto.Adapter.Schema
  def insert_all(%{repo: repo}, %{schema: schema}, _, entries, _, _, _, _) do
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    ets_field_names = TableStructure.field_names(schema)
    ets_changes = TableStructure.entries_to_tuples(ets_field_names, entries)
    ets_result = :ets.insert_new(ets_table, ets_changes)
    if ets_result, do: {length(ets_changes), nil}, else: {0, nil}
  end

  @impl Ecto.Adapter.Schema
  def insert(%{repo: repo}, %{schema: schema}, fields, _, _, _) do
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    ets_field_names = TableStructure.field_names(schema)
    ets_changes = TableStructure.fields_to_tuple(ets_field_names, fields)
    ets_result = :ets.insert_new(ets_table, ets_changes)
    if ets_result, do: {:ok, []}, else: {:invalid, [unique: "primary_key"]}
  end

  @impl Ecto.Adapter.Schema
  def update(%{repo: repo}, %{schema: schema}, fields, filters, [], _) do
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    [key_name] = schema.__schema__(:primary_key)
    [{^key_name, key}] = filters
    ets_updates = build_ets_updates(schema, fields)
    ets_result = :ets.update_element(ets_table, key, ets_updates)
    if ets_result, do: {:ok, []}, else: {:error, :stale}
  end

  @impl Ecto.Adapter.Schema
  def delete(%{repo: repo}, %{schema: schema}, filters, _) do
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    [key_name] = schema.__schema__(:primary_key)
    [{^key_name, key}] = filters
    :ets.delete(ets_table, key)
    {:ok, []}
  end

  defp build_ets_updates(schema, fields) do
    ets_field_names = TableStructure.field_names(schema)

    for {field_name, field_value} <- fields do
      position_fun = fn x -> x == field_name end
      position = 1 + Enum.find_index(ets_field_names, position_fun)
      {position, field_value}
    end
  end
end
