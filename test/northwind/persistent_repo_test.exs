defmodule Northwind.PersistentRepoTest do
  use ExUnit.Case

  alias Northwind.{Repo, Model}

  @path "test/temp"

  setup_all do
    File.mkdir("test/temp")
    :ok
  end

  setup do
    File.ls!(@path)
    |> Enum.map(fn file -> Path.join(@path, file) end)

    :ok
  end

  def start_repo do
    repo_id = __MODULE__
    repo_start = {Northwind.Repo, :start_link, [[persist_to_dets: true, dets_folder: @path]]}
    start_supervised(%{id: repo_id, start: repo_start})
  end

  def stop_repo do
    repo_id = __MODULE__
    stop_supervised(repo_id)
  end

  test "create file if not exist" do
    start_repo()
    assert File.ls!(@path) |> length() > 0
  end

  test "data persisted between runs" do
    start_repo()
    changes = %{first_name: "Evadne", employee_id: 1024}
    changeset = Model.Employee.changeset(changes)
    Repo.insert(changeset)

    stop_repo()
    start_repo()

    assert Repo.all(Model.Employee) != []
  end
end
