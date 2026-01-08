defmodule Etso.ETS.ObjectsSorter do
  @moduledoc """
  The ETS Objects Sorter module is responsible for sorting results returned from ETS according to
  the sort predicates provided in the query.
  """

  def sort(ets_objects, %Ecto.Query{order_bys: []}) do
    ets_objects
  end

  def sort(ets_objects, %Ecto.Query{} = query) do
    sort_predicates = build_sort_predicates(query)
    Enum.sort_by(ets_objects, & &1, &compare(&1, &2, sort_predicates))
  end

  defp build_sort_predicates(%Ecto.Query{} = query) do
    # FIXME: If the field is a function then the objects should be sorted
    # based on the result of evaluating such function. The current implementation
    # would only sort fields as-is

    Enum.flat_map(query.order_bys, fn %Ecto.Query.ByExpr{expr: list} ->
      Enum.map(list, fn {direction, order_by_field} ->
        field_name = get_field_name(order_by_field)

        {direction, Enum.find_index(query.select.fields, fn select_field ->
          get_field_name(select_field) == field_name
        end)}
      end)
    end)
  end
  
  defp get_field_name({{:., _, [{:&, _, [_]}, field_name]}, _, []}) do
    # the field format is per Ecto.Query.field(index, field_name)
    field_name
  end
  
  defp compare(lhs, rhs, [{direction, index} | predicates]) do
    case {direction, Enum.at(lhs, index), Enum.at(rhs, index)} do
      {_, lhs, rhs} when lhs == rhs -> compare(lhs, rhs, predicates)
      {:asc, lhs, rhs} -> lhs < rhs
      {:desc, lhs, rhs} -> lhs > rhs
    end
  end

  defp compare(_lhs, _rhs, []) do
    true
  end
end
