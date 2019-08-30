defmodule Northwind.Model.Shipper do
  use Northwind.Model
  @primary_key {:shipper_id, :id, autogenerate: false}

  schema "shippers" do
    field :company_name, :string
    field :phone, :string
    # field :shipper_id, :integer

    has_many :orders, Model.Order,
      foreign_key: :ship_via,
      references: :shipper_id
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
