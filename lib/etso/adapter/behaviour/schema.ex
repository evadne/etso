defmodule Etso.Adapter.Behaviour.Schema do
  defmacro __using__(_) do
    quote do
      @behaviour Ecto.Adapter.Schema

      def autogenerate(:id), do: :erlang.unique_integer()
      def autogenerate(:binary_id), do: Ecto.UUID.bingenerate()
      def autogenerate(:embed_id), do: Ecto.UUID.bingenerate()

      def insert_all(adapter_meta, schema_meta, _header, entries, on_conflict, returning, options) do
        %{schema: schema, source: source} = schema_meta
        ets_table = get_table(adapter_meta, schema)
        ets_field_names = Etso.ETS.TableStructure.field_names(schema)
        ets_changes = Etso.ETS.TableStructure.entries_to_tuples(ets_field_names, entries)
        ets_result = :ets.insert_new(ets_table, ets_changes)
        if ets_result, do: {length(ets_changes), nil}, else: {0, nil}
      end

      def insert(adapter_meta, schema_meta, fields, on_conflict, returning, options) do
        %{schema: schema, source: source} = schema_meta
        ets_table = get_table(adapter_meta, schema)
        ets_field_names = Etso.ETS.TableStructure.field_names(schema)
        ets_changes = Etso.ETS.TableStructure.fields_to_tuple(ets_field_names, fields)
        ets_result = :ets.insert_new(ets_table, ets_changes)
        if ets_result, do: {:ok, []}, else: {:invalid, []}
      end

      def update(adapter_meta, schema_meta, fields, filters, [] = returning, _options) do
        %{schema: schema, source: source} = schema_meta
        [key_name] = schema.__schema__(:primary_key)
        [{^key_name, key}] = filters
        ets_updates = build_ets_updates(schema, fields)
        ets_table = get_table(adapter_meta, schema)
        ets_result = :ets.update_element(ets_table, key, ets_updates)
        if ets_result, do: {:ok, []}, else: {:error, :stale}
      end

      def delete(adapter_meta, schema_meta, filters, _options) do
        %{schema: schema, source: source} = schema_meta
        [key_name] = schema.__schema__(:primary_key)
        [{^key_name, key}] = filters
        ets_table = get_table(adapter_meta, schema)
        ets_result = :ets.delete(ets_table, key)
        {:ok, []}
      end

      defp build_ets_updates(schema, fields) do
        ets_field_names = Etso.ETS.TableStructure.field_names(schema)

        for {field_name, field_value} <- fields do
          position_fun = fn x -> x == field_name end
          position = 1 + Enum.find_index(ets_field_names, position_fun)
          {position, field_value}
        end
      end
    end
  end
end
