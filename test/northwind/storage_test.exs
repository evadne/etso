defmodule Northwind.StorageTest do
  use ExUnit.Case
  alias Northwind.{Importer, Model, Repo}
  import Ecto.Query

  setup do
    repo_id = __MODULE__
    repo_start = {Repo, :start_link, []}
    {:ok, _} = start_supervised(%{id: repo_id, start: repo_start})
    :ok
  end

  test "repo started with Up status" do
    assert :up = Repo.__adapter__.storage_status(Repo.config)
    assert_empty()
  end

  test "repo up/down roundtrip is no-op" do
    :ok = Importer.perform()
    assert_not_empty()
    assert :ok = Repo.__adapter__.storage_down(Repo.config)
    assert_not_empty()
    assert :ok = Repo.__adapter__.storage_up(Repo.config)
    assert_not_empty()
  end

  defp assert_empty do
    Model.Employee
    |> where([x], x.employee_id in [3, 5, 7])
    |> select([x], x.employee_id)
    |> Repo.all()
    |> (&assert(&1 == [])).()
  end

  defp assert_not_empty do
    Model.Employee
    |> where([x], x.employee_id in [3, 5, 7])
    |> select([x], x.employee_id)
    |> Repo.all()
    |> Enum.sort()
    |> (&assert(&1 == [3, 5, 7])).()
  end
end
