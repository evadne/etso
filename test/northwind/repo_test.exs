defmodule Northwind.RepoTest do
  use ExUnit.Case
  alias Northwind.{Importer, Model, Repo}
  import Ecto.Query

  setup do
    repo_id = __MODULE__
    repo_start = {Northwind.Repo, :start_link, []}
    {:ok, _} = start_supervised(%{id: repo_id, start: repo_start})
    :ok = Importer.perform()
  end

  test "list" do
    Repo.all(Model.Employee)
  end

  test "Insert / Delete Employee" do
    changes = %{first_name: "Evadne", employee_id: 1024}
    changeset = Model.Employee.changeset(changes)
    {:ok, employee} = Repo.insert(changeset)
    Repo.delete(employee)
  end

  test "Insert Employees" do
    changes = [%{first_name: "Fred", employee_id: 100}, %{first_name: "Steven", employee_id: 200}]
    nil = Repo.get(Model.Employee, 100)

    Repo.insert_all(Model.Employee, changes)
    %{first_name: "Fred"} = Repo.get(Model.Employee, 100)
  end

  test "List all Employees Again" do
    Repo.all(Model.Employee)
  end

  test "Select with Bound ID" do
    Repo.get(Model.Employee, 2)
  end

  test "Where" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
    |> Repo.all()
  end

  test "Where In None" do
    employee_ids = []

    Model.Employee
    |> where([x], x.employee_id in ^employee_ids)
    |> select([x], x.employee_id)
    |> Repo.all()
    |> Enum.sort()
    |> (&assert(&1 == employee_ids)).()
  end

  test "Where In One" do
    employee_ids = [3]

    Model.Employee
    |> where([x], x.employee_id in ^employee_ids)
    |> select([x], x.employee_id)
    |> Repo.all()
    |> Enum.sort()
    |> (&assert(&1 == employee_ids)).()
  end

  test "Where In Multiple" do
    employee_ids = [3, 5, 7]

    Model.Employee
    |> where([x], x.employee_id in ^employee_ids)
    |> select([x], x.employee_id)
    |> Repo.all()
    |> Enum.sort()
    |> (&assert(&1 == employee_ids)).()
  end

  test "Where In Nested" do
    employee_ids = [3, 5, 7]
    employee_first_names = ["Janet"]

    Model.Employee
    |> where([x], x.employee_id in ^employee_ids)
    |> where([x], x.first_name in ^employee_first_names)
    |> select([x], x.employee_id)
    |> Repo.all()
    |> Enum.sort()
    |> (&assert(&1 == [3])).()
  end

  test "Select Where" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
    |> select([x], x.last_name)
    |> Repo.all()
  end

  test "Select Where Is Nil" do
    query = Model.Employee |> where([x], is_nil(x.title))
    assert [] = Repo.all(query)

    changes = %{first_name: "Ghost", employee_id: 4096}
    changeset = Model.Employee.changeset(changes)
    {:ok, %{employee_id: employee_id} = employee} = Repo.insert(changeset)
    assert [%{employee_id: ^employee_id}] = Repo.all(query)
    Repo.delete(employee)
  end

  test "Select / Update" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales")
    |> Repo.all()
    |> List.first()
    |> Model.Employee.changeset(%{title: "SVP Sales"})
    |> Repo.update()
  end

  test "Assoc Traversal" do
    Model.Employee
    |> Repo.get(5)
    |> Ecto.assoc(:reports)
    |> Repo.all()
    |> List.first()
    |> Ecto.assoc(:manager)
    |> Repo.one()
    |> Ecto.assoc(:reports)
    |> Repo.all()
  end

  test "Promote to Customer" do
    Model.Employee
    |> where([x], x.title == "Vice President Sales" and x.first_name == "Andrew")
    |> Repo.one()
    |> Model.Employee.changeset(%{title: "Customer"})
    |> Repo.update()
  end

  test "Stream Employees" do
    Model.Employee
    |> Repo.stream()
    |> Enum.to_list()
  end

  test "Order / Shipper / Orders Preloading" do
    Model.Order
    |> Repo.all()
    |> Repo.preload(shipper: :orders)
  end

  test "Support json_extract_path expression" do
    from(e in Model.Employee)
    |> where([e], e.metadata["twitter"] == "@andrew_fuller")
    |> Repo.one!()
  end

  test "Order / Shipper + Employee Preloading" do
    Model.Order
    |> Repo.all()
    |> Repo.preload([[shipper: :orders], :employee, :customer], in_parallel: true)
  end

  test "Order / Shipper / Orders Preloading before all()" do
    Model.Order
    |> preload([_], shipper: :orders)
    |> Repo.all()
  end

  test "Order By Desc company_name, Asc phone" do
    sorted_etso =
      Model.Shipper
      |> order_by([x], desc: x.company_name, asc: x.phone)
      |> Repo.all()

    sorted_code =
      Model.Shipper
      |> Repo.all()
      |> Enum.sort_by(& &1.company_name, :desc)
      |> Enum.sort_by(& &1.phone)

    assert sorted_etso == sorted_code
  end
end
