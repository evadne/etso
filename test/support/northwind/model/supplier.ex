defmodule Northwind.Model.Supplier do
  use Northwind.Model
  @primary_key {:supplier_id, :id, autogenerate: false}

  schema "suppliers" do
    field :company_name, :string
    field :contact_name, :string
    field :contact_title, :string

    # field :supplier_id, :integer

    embeds_one :address, Model.Address
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
