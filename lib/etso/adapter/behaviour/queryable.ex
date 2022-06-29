defmodule Etso.Adapter.Behaviour.Queryable do
  @moduledoc false
  @behaviour Ecto.Adapter.Queryable

  alias Etso.Adapter.TableRegistry
  alias Etso.ETS.MatchSpecification
  alias Etso.ETS.ObjectsSorter

  @impl Ecto.Adapter.Queryable
  def prepare(:all, %Ecto.Query{} = query) do
    {:nocache, {:select, query}}
  end

  @impl Ecto.Adapter.Queryable
  def prepare(:delete_all, %Ecto.Query{wheres: []} = query) do
    {:nocache, {:delete_all_objects, query}}
  end

  @impl Ecto.Adapter.Queryable
  def prepare(:delete_all, %Ecto.Query{wheres: _} = query) do
    {:nocache, {:match_delete, query}}
  end

  @impl Ecto.Adapter.Queryable
  def execute(%{repo: repo}, _, {:nocache, {:select, query}}, params, _) do
    {_, schema} = query.from.source
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    ets_match = MatchSpecification.build(query, params)
    ets_objects = :ets.select(ets_table, [ets_match])
    ets_count = length(ets_objects)
    {ets_count, ObjectsSorter.sort(ets_objects, query)}
  end

  @impl Ecto.Adapter.Queryable
  def execute(%{repo: repo}, _, {:nocache, {:delete_all_objects, query}}, params, _) do
    {_, schema} = query.from.source
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    ets_match = MatchSpecification.build(query, params)
    ets_objects = query.select && ObjectsSorter.sort(:ets.select(ets_table, [ets_match]), query)
    ets_count = :ets.info(ets_table, :size)
    true = :ets.delete_all_objects(ets_table)
    {ets_count, ets_objects || nil}
  end

  @impl Ecto.Adapter.Queryable
  def execute(%{repo: repo}, _, {:nocache, {:match_delete, query}}, params, _) do
    {_, schema} = query.from.source
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    ets_match = MatchSpecification.build(query, params)
    ets_objects = query.select && ObjectsSorter.sort(:ets.select(ets_table, [ets_match]), query)
    {ets_match_head, ets_match_body, _} = ets_match
    ets_match = {ets_match_head, ets_match_body, [true]}
    ets_count = :ets.select_delete(ets_table, [ets_match])
    {ets_count, ets_objects || nil}
  end

  @impl Ecto.Adapter.Queryable
  def stream(%{repo: repo}, _, {:nocache, {:select, query}}, params, options) do
    {_, schema} = query.from.source
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    ets_match = MatchSpecification.build(query, params)
    ets_limit = Keyword.get(options, :max_rows, 500)
    stream_start_fun = fn -> stream_start(ets_table, ets_match, ets_limit) end
    stream_next_fun = fn acc -> stream_next(acc) end
    stream_after_fun = fn acc -> stream_after(ets_table, acc) end
    Stream.resource(stream_start_fun, stream_next_fun, stream_after_fun)
  end

  defp stream_start(ets_table, ets_match, ets_limit) do
    :ets.safe_fixtable(ets_table, true)
    :ets.select(ets_table, [ets_match], ets_limit)
  end

  defp stream_next(:"$end_of_table") do
    {:halt, :ok}
  end

  defp stream_next({ets_objects, ets_continuation}) do
    {[{length(ets_objects), ets_objects}], :ets.select(ets_continuation)}
  end

  defp stream_after(ets_table, :ok) do
    :ets.safe_fixtable(ets_table, false)
  end

  defp stream_after(_, acc) do
    acc
  end
end
