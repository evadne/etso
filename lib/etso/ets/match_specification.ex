defmodule Etso.ETS.MatchSpecification do
  @moduledoc """
  The ETS Match Specifications module contains various functions which convert Ecto queries to
  [ETS Match Specifications](https://www.erlang.org/doc/apps/erts/match_spec.html) in order to
  execute the given queries with ETS with as much pushed down to ETS as possible.

  The basic shape of the match head is `[$1, $2, $3, …]` where each field is a named variable, the
  ordering of the fields is determined by `Etso.ETS.TableStructure`.

  Conditions are compiled according to the wheres in the underlying Ecto query, while the body is
  compiled based on the selected fields in the underlying Ecto query.
  """

  def build(query, params) do
    {_, schema} = query.from.source
    field_names = Etso.ETS.TableStructure.field_names(schema)
    match_head = build_head(field_names)
    match_conditions = build_conditions(field_names, params, query)
    match_body = [build_body(field_names, query)]
    {match_head, match_conditions, match_body}
  end

  defp build_head(field_names) do
    List.to_tuple(Enum.map(1..length(field_names), fn x -> :"$#{x}" end))
  end

  defp build_conditions(field_names, params, %Ecto.Query{wheres: wheres}) do
    Enum.reduce(wheres, [], fn %Ecto.Query.BooleanExpr{expr: expression}, acc ->
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

  defp build_condition(field_names, params, {:in, [], [field, values]}) do
    field_target = resolve_field_target(field_names, field)

    case resolve_param_values(params, values) do
      [] -> []
      values -> List.to_tuple([:orelse | Enum.map(values, &{:==, field_target, &1})])
    end
  end

  defp build_condition(field_names, params, {:is_nil, [], [field]}) do
    {:==, build_condition(field_names, params, field), nil}
  end

  defp build_condition(_, params, {:^, [], [index]}) do
    Enum.at(params, index)
  end

  defp build_condition(field_names, _params, field) when is_tuple(field) do
    resolve_field_target(field_names, field)
  end

  defp build_condition(_, _, value) do
    value
  end

  defp build_body(_, %Ecto.Query{select: nil}) do
    []
  end

  defp build_body(field_names, %Ecto.Query{select: %{fields: fields}}) do
    for field <- fields do
      resolve_field_target(field_names, field)
    end
  end

  defp resolve_field_target(field_names, {:json_extract_path, [], [field, path]}) do
    field_target = resolve_field_target(field_names, field)
    resolve_field_target_path(field_target, path)
  end

  defp resolve_field_target(field_names, {{:., _, [{:&, [], [0]}, field_name]}, [], []}) do
    field_index = 1 + Enum.find_index(field_names, fn x -> x == field_name end)
    :"$#{field_index}"
  end

  defp resolve_field_target_path(field_target, path) do
    # - If the path component is a key, return {:map_get, key, target}
    # - If the path component is a number, return {:hd, target} outside as many {:tl, _} around
    #   as required. For example, [:metadata, 0] would be {:hd, {:map_get, :metadata, field}},
    #   while [:metadata, 1] would be {:hd, {:tl, {:map_get, :metadata, field}}} (with one tl).

    at = fn self ->
      fn
        condition, 0 -> {:hd, condition}
        condition, index -> self.(self).({:tl, condition}, index - 1)
      end
    end

    Enum.reduce(path, field_target, fn
      key, condition when is_atom(key) or is_binary(key) -> {:map_get, key, condition}
      index, condition when is_integer(index) -> at.(at).(condition, index)
    end)
  end

  defp resolve_param_values(params, {:^, [], [index, count]}) do
    for index <- index..(index + count - 1) do
      Enum.at(params, index)
    end
  end

  defp resolve_param_values(_params, values) when is_list(values) do
    values
  end
end
