defmodule Northwind.Model.EmployeeTeam do
  use Ecto.Schema

  @primary_key false
  schema "employees_teams" do
    belongs_to :employee, Northwind.Model.Employee, references: :employee_id
    belongs_to :team, Northwind.Model.Team, references: :team_id

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:user_id, :organization_id])
    |> Ecto.Changeset.validate_required([:user_id, :organization_id])
  end
end
