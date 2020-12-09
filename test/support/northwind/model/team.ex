defmodule Northwind.Model.Team do
  use Northwind.Model
  @primary_key {:team_id, :id, autogenerate: false}

  schema "teams" do
    # field :team_id, :integer
    field :description, :string
    field :name, :string

    has_many :members, Northwind.Model.EmployeeTeam,
      foreign_key: :team_id,
      references: :team_id
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
