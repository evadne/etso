defmodule Etso.ETS.TableStructure do
  @moduledoc """
  The ETS Table Structure module contains various convenience functions to aid the transformation
  between Ecto Schemas (maps) and ETS entries (tuples). The primary key is moved to the head, in
  accordance with ETS conventions. Composite primary keys can not be accepted, however.
  """

  def field_names(schema) do
    fields = schema.__schema__(:fields)
    primary_key = schema.__schema__(:primary_key)
    primary_key ++ (fields -- primary_key)
  end

  def field_sources(schema) do
    schema
    |> field_names()
    |> Enum.map(fn field -> schema.__schema__(:field_source, field) end)
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
