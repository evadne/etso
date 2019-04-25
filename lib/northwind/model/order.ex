defmodule Northwind.Model.Order do
  use Northwind.Model
  @primary_key {:order_id, :id, autogenerate: false}

  schema "orders" do
    field :customer_id, :string
    field :employee_id, :integer
    field :freight, :float
    field :order_date, :date
    # field :order_id, :integer
    field :required_date, :date
    field :ship_name, :string
    field :ship_via, :integer
    field :shipped_date, :date

    embeds_one :ship_address, Model.Address
    embeds_many :details, __MODULE__.Details

    belongs_to :customer, Model.Customer,
      foreign_key: :customer_id,
      references: :customer_id,
      define_field: false

    belongs_to :employee, Model.Employee,
      foreign_key: :employee_id,
      references: :employee_id,
      define_field: false

    belongs_to :shipper, Model.Shipper,
      foreign_key: :ship_via,
      references: :shipper_id,
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
