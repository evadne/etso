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
    selected_fields = selected_field_names(query)

    Enum.flat_map(query.order_bys, fn order_by ->
      expr = Map.get(order_by, :expr) || []
      Enum.map(List.wrap(expr), &build_sort_predicate(&1, selected_fields))
    end)
  end

  defp selected_field_names(%Ecto.Query{} = query) do
    case query do
      %Ecto.Query{select: %{fields: fields}} when is_list(fields) and fields != [] ->
        fields
        |> Enum.flat_map(&extract_field_names/1)

      %Ecto.Query{select: %{expr: expr}} ->
        case extract_field_names(expr) do
          [] -> schema_field_names(query)
          names -> names
        end

      %Ecto.Query{} ->
        schema_field_names(query)
    end
  end

  defp schema_field_names(%Ecto.Query{from: %{source: {_, schema}}}) when is_atom(schema), do: Etso.ETS.TableStructure.field_names(schema)
  defp schema_field_names(%Ecto.Query{from: %{source: schema}}) when is_atom(schema), do: Etso.ETS.TableStructure.field_names(schema)
  defp schema_field_names(_query), do: []

  defp extract_field_names({:{}, _, entries}) do
    Enum.flat_map(entries, &extract_field_names/1)
  end

  defp extract_field_names({:__block__, _, [expr]}) do
    extract_field_names(expr)
  end

  defp extract_field_names({{:., _, [{:&, [], [0]}, field_name]}, [], []}) do
    [field_name]
  end

  defp extract_field_names(_other), do: []

  defp build_sort_predicate({direction, field_ast}, selected_fields) do
    field_name = field_name(field_ast)
    {direction, field_name, field_index(field_name, selected_fields)}
  end

  defp field_name({{:., _, [{:&, [], [0]}, field_name]}, [], []}), do: field_name
  defp field_name(_field), do: nil

  defp field_index(field_name, selected_fields) do
    Enum.find_index(selected_fields, &(&1 == field_name)) || 0
  end

  defp compare(_lhs, _rhs, []), do: false

  defp compare(lhs, rhs, [{direction, field_name, index} | predicates]) do
    lhs_value = value_at(lhs, field_name, index)
    rhs_value = value_at(rhs, field_name, index)

    case {direction, lhs_value, rhs_value} do
      {_, lhs_value, rhs_value} when lhs_value == rhs_value ->
        compare(lhs, rhs, predicates)

      {:asc, lhs_value, rhs_value} -> lhs_value < rhs_value
      {:desc, lhs_value, rhs_value} -> lhs_value > rhs_value
    end
  end

  defp value_at(tuple, _field_name, index) when is_tuple(tuple), do: elem(tuple, index)
  defp value_at(list, _field_name, index) when is_list(list), do: Enum.at(list, index)
  defp value_at(map, field_name, _index) when is_map(map), do: Map.get(map, field_name)
  defp value_at(_value, _field_name, _index), do: nil
end
