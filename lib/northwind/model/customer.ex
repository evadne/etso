defmodule Northwind.Model.Customer do
  use Northwind.Model
  @primary_key {:customer_id, :string, autogenerate: false}

  schema "customers" do
    field :company_name, :string
    field :contact_name, :string
    field :contact_title, :string
    # field :customer_id, :string
    embeds_one :address, Model.Address

    has_many :orders, Model.Order,
      foreign_key: :customer_id,
      references: :customer_id
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
