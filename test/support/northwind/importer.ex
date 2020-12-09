defmodule Northwind.Importer do
  alias Northwind.{Model, Repo}

  @otp_app Mix.Project.config()[:app]
  @models [
    Model.Category,
    Model.Customer,
    Model.Employee,
    Model.Team,
    Model.EmployeeTeam,
    Model.Order,
    Model.Product,
    Model.Shipper,
    Model.Supplier
  ]

  def perform(method \\ :changesets) do
    for schema <- @models, do: perform(schema, method)
    :ok
  end

  def perform(schema, method) do
    insert(schema, method, Enum.map(load(schema), &transform_keys/1))
  end

  defp load(schema) do
    file_path_fragment = "priv/northwind/#{schema.__schema__(:source)}.json"
    file_path = Application.app_dir(@otp_app, file_path_fragment)
    {:ok, file_content} = File.read(file_path)
    {:ok, representations} = Jason.decode(file_content)
    representations
  end

  defp insert(schema, :changesets, representations) do
    for representation <- representations do
      changeset = schema.changeset(representation)
      %{valid?: true} = changeset
      {:ok, entity} = Repo.insert(changeset)
      entity
    end
  end

  defp insert(schema, :insert_all_maps, representations) do
    Repo.insert_all(schema, flatten_representations(schema, representations, %{}))
  end

  defp insert(schema, :insert_all_keywords, representations) do
    Repo.insert_all(schema, flatten_representations(schema, representations, []))
  end

  defp transform_keys(map) when is_map(map) do
    for {key, value} <- map, into: %{} do
      key = key |> Macro.underscore() |> String.replace_suffix("_i_ds", "_ids")
      {key, transform_keys(value)}
    end
  end

  defp transform_keys(value) do
    value
  end

  defp flatten_representations(schema, representations, into_enum) do
    for representation <- representations do
      changeset = schema.changeset(representation)
      %{valid?: true} = changeset
      model = flatten_changeset(changeset)

      for field <- schema.__schema__(:fields), into: into_enum do
        {field, Map.get(model, field)}
      end
    end
  end

  defp flatten_changeset(%Ecto.Changeset{} = changeset) do
    changes = for {k, v} <- changeset.changes, into: %{}, do: {k, flatten_changeset(v)}
    Map.merge(changeset.data, changes)
  end

  defp flatten_changeset(values) when is_list(values) do
    Enum.map(values, &flatten_changeset/1)
  end

  defp flatten_changeset(value) do
    value
  end
end
