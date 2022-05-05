defmodule Etso.Ecto.MapType do
  use Ecto.Type
  def type, do: :map

  def cast(map) when is_map(map) do
    {:ok, map}
  end

  # Everything else is a failure though
  def cast(_), do: :error

  # When loading data from the database, as long as it's a map,
  # we just put the data back into a URI struct to be stored in
  # the loaded schema struct.
  def load(data) when is_map(data) do
    {:ok, data}
  end

  # When dumping data to the database, we *expect* a URI struct
  # but any value could be inserted into the schema struct at runtime,
  # so we need to guard against them.
  def dump(%{} = map), do: {:ok, map_keys_to_string(map)}
  def dump(_), do: :error

  defp map_keys_to_string(value) when is_map(value) and not is_struct(value) do
    value
    |> Enum.map(fn {key, value} -> {to_string(key), map_keys_to_string(value)} end)
    |> Enum.into(%{})
  end

  defp map_keys_to_string(%{__struct__: module} = value)
       when module not in [Date, DateTime, Decimal, NaiveDateTime, Time] do
    value
    |> Map.from_struct()
    |> map_keys_to_string()
  end

  defp map_keys_to_string(value) when is_list(value) do
    Enum.map(value, &map_keys_to_string/1)
  end

  defp map_keys_to_string(value), do: value
end
