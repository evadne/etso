defmodule Northwind.Model.Category do
  use Northwind.Model
  @primary_key {:category_id, :id, autogenerate: false}

  schema "categories" do
    # field :category_id, :integer
    field :description, :string
    field :name, :string
  end

  def changeset(params \\ %{}) do
    changeset(%__MODULE__{}, params)
  end

  def changeset(model, params) do
    fields = __MODULE__.__schema__(:fields)
    embeds = __MODULE__.__schema__(:embeds)
    cast_model = cast(model, params, fields -- embeds)

    Enum.reduce(embeds, cast_model, fn embed, model ->
      cast_embed(model, embed)
    end)
  end
end
