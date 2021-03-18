defmodule Etso.Adapter.Behaviour.Queryable do
  @moduledoc false

  alias Etso.Adapter.TableRegistry
  alias Etso.ETS.MatchSpecification
  alias Etso.ETS.TableSorter

  def prepare(:all, query) do
    {:nocache, query}
  end

  def execute(%{repo: repo}, _, {:nocache, query}, params, _) do
    {_, schema} = query.from.source
    {:ok, ets_table} = TableRegistry.get_table(repo, schema)
    ets_match = MatchSpecification.build(query, params)

    ets_objects =
      ets_table
      |> :ets.select([ets_match])
      |> TableSorter.sort(query)

    {length(ets_objects), ets_objects}
  end

  def stream(%{repo: repo}, _, {:nocache, query}, params, options) do
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
