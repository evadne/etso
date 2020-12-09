defmodule Northwind.Model.EmployeeTeam do
  use Northwind.Model

  schema "employees_teams" do
    belongs_to :employee, Northwind.Model.Employee, references: :employee_id
    belongs_to :team, Northwind.Model.Team, references: :team_id

    timestamps()
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
