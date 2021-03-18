defmodule Etso.ETS.TableSorter do
  @moduledoc """
  This module is used to sort the list of ETS objects based
  on the order by clause and fields in the query.
  """

  def sort(ets_objects, query) do
    orders =
      Enum.flat_map(query.order_bys, fn %{expr: order_bys} ->
        Enum.map(order_bys, fn {order, {{:., [], [{:&, [], [0]}, field]}, [], []}} ->
          {field, order}
        end)
      end)

    select_fields =
      Enum.map(query.select.fields, fn {{:., _, [{:&, [], [0]}, field]}, [], []} -> field end)

    ets_objects
    |> Enum.map(fn object ->
      select_fields
      |> Enum.zip(object)
      |> Enum.into(%{})
    end)
    |> Enum.sort_by(& &1, build_sorter(orders))
    |> Enum.map(fn object -> Enum.map(select_fields, &Map.fetch!(object, &1)) end)
  end

  defp build_sorter(sort_keys) do
    sort_keys
    |> Enum.reverse()
    |> Enum.reduce(fn _, _ -> true end, fn {key, order}, acc ->
      build_sorter_by_order(order, key, acc)
    end)
  end

  def build_sorter_by_order(:asc, key, next_cond_fun) do
    fn lhs, rhs ->
      lval = Map.fetch!(lhs, key)
      rval = Map.fetch!(rhs, key)

      cond do
        lval < rval -> true
        lval > rval -> false
        true -> next_cond_fun.(lhs, rhs)
      end
    end
  end

  def build_sorter_by_order(:desc, key, next_cond_fun) do
    fn lhs, rhs ->
      lval = Map.fetch!(lhs, key)
      rval = Map.fetch!(rhs, key)

      cond do
        lval > rval -> true
        lval < rval -> false
        true -> next_cond_fun.(lhs, rhs)
      end
    end
  end
end
