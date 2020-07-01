defmodule Etso.ETS.MatchSpecification do
  @moduledoc """
  The ETS Match Specifications module contains various functions which convert Ecto queries to
  ETS Match Specifications in order to execute the given queries.
  """

  def build(query, params) do
    {_, schema} = query.from.source
    field_names = Etso.ETS.TableStructure.field_names(schema)

    match_head = build_head(field_names)
    match_conditions = build_conditions(field_names, params, query.wheres)
    match_body = [build_body(field_names, query.select.fields)]
    {match_head, match_conditions, match_body}
  end

  defp build_head(field_names) do
    List.to_tuple(Enum.map(1..length(field_names), fn x -> :"$#{x}" end))
  end

  defp build_conditions(field_names, params, query_wheres) do
    Enum.reduce(query_wheres, [], fn %Ecto.Query.BooleanExpr{expr: expression}, acc ->
      [build_condition(field_names, params, expression) | acc]
    end)
  end

  defmacrop guard_operator(:and), do: :andalso
  defmacrop guard_operator(:or), do: :orelse
  defmacrop guard_operator(:!=), do: :"/="
  defmacrop guard_operator(:<=), do: :"=<"
  defmacrop guard_operator(operator), do: operator

  for operator <- ~w(== != < > <= >= and or)a do
    defp build_condition(field_names, params, {unquote(operator), [], [lhs, rhs]}) do
      lhs_condition = build_condition(field_names, params, lhs)
      rhs_condition = build_condition(field_names, params, rhs)
      {guard_operator(unquote(operator)), lhs_condition, rhs_condition}
    end
  end

  for operator <- ~w(not)a do
    defp build_condition(field_names, params, {unquote(operator), [], [clause]}) do
      condition = build_condition(field_names, params, clause)
      {guard_operator(unquote(operator)), condition}
    end
  end

  defp build_condition(field_names, params, {:in, [], [field, value]}) do
    field_name = resolve_field_name(field)
    field_index = get_field_index(field_names, field_name)

    resolve_field_values(params, value)
    |> Enum.map(&{:==, :"$#{field_index}", &1})
    |> Enum.reduce(&{:orelse, &1, &2})
  end

  defp build_condition(field_names, _, {{:., [], [{:&, [], [0]}, field_name]}, [], []}) do
    :"$#{get_field_index(field_names, field_name)}"
  end

  defp build_condition(_, params, {:^, [], [index]}) do
    Enum.at(params, index)
  end

  defp build_condition(_, _, value) when not is_tuple(value) do
    value
  end

  defp build_body(field_names, query_select_fields) do
    for select_field <- query_select_fields do
      field_name = resolve_field_name(select_field)
      field_index = get_field_index(field_names, field_name)
      :"$#{field_index}"
    end
  end

  defp resolve_field_name(field) do
    {{:., _, [{:&, [], [0]}, field_name]}, [], []} = field
    field_name
  end

  defp resolve_field_values(params, {:^, [], [start, stop]}) do
    for index <- start..(stop - 1) do
      Enum.at(params, index)
    end
  end

  defp resolve_field_values(params, {:^, [], indices}) do
    for index <- indices do
      Enum.at(params, index)
    end
  end

  defp get_field_index(field_names, field_name) do
    1 + Enum.find_index(field_names, fn x -> x == field_name end)
  end
end
