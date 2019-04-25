defmodule Northwind.Model.Product do
  use Northwind.Model
  @primary_key {:product_id, :id, autogenerate: false}

  schema "products" do
    field :category_id, :integer
    field :discontinued, :boolean
    field :name, :string
    # field :product_id, :integer
    field :quantity_per_unit, :string
    field :reorder_level, :integer
    field :supplier_id, :integer
    field :unit_price, :decimal
    field :units_in_stock, :integer
    field :units_on_order, :integer

    belongs_to :category, Model.Category,
      foreign_key: :category_id,
      references: :category_id,
      define_field: false

    belongs_to :supplier, Model.Supplier,
      foreign_key: :supplier_id,
      references: :supplier_id,
      define_field: false
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
