defmodule Northwind.Model.Employee do
  use Northwind.Model
  @primary_key {:employee_id, :id, autogenerate: false}

  schema "employees" do
    # field :employee_id, :integer
    field :reports_to, :integer
    field :first_name, :string
    field :last_name, :string
    field :title, :string
    field :title_of_courtesy, :string
    field :birth_date, :date
    field :hire_date, :date
    field :notes, :string
    field :territory_ids, {:array, :integer}
    field :metadata, :map, default: %{}

    embeds_one :address, Model.Address

    belongs_to :manager, __MODULE__,
      foreign_key: :reports_to,
      references: :employee_id,
      define_field: false

    has_many :reports, __MODULE__,
      foreign_key: :reports_to,
      references: :employee_id

    has_many :orders, Model.Order,
      foreign_key: :employee_id,
      references: :employee_id
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
