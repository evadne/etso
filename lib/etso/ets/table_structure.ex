defmodule Etso.ETS.TableStructure do
  def field_names(schema) do
    fields = schema.__schema__(:fields)
    primary_key = schema.__schema__(:primary_key)
    primary_key ++ (fields -- primary_key)
  end

  def fields_to_tuple(field_names, fields) do
    field_names
    |> Enum.map(&Keyword.get(fields, &1, nil))
    |> List.to_tuple()
  end

  def entries_to_tuples(field_names, entries) do
    for entry <- entries do
      fields_to_tuple(field_names, entry)
    end
  end
end
