defmodule Northwind.ImporterTest do
  use ExUnit.Case
  alias Northwind.Importer
  alias Northwind.Model
  alias Northwind.Repo

  setup do
    repo_id = __MODULE__
    repo_start = {Repo, :start_link, []}
    {:ok, _} = start_supervised(%{id: repo_id, start: repo_start})
    :ok
  end

  test "via changesets" do
    :ok = Importer.perform(:changesets)
    refute_empty()
  end

  test "via insert_all as maps" do
    :ok = Importer.perform(:insert_all_maps)
    refute_empty()
  end

  test "via insert_all as keywords" do
    :ok = Importer.perform(:insert_all_keywords)
    refute_empty()
  end

  defp refute_empty do
    refute match?([], Repo.all(Model.Category))
    refute match?([], Repo.all(Model.Customer))
    refute match?([], Repo.all(Model.Employee))
    refute match?([], Repo.all(Model.Order))
    refute match?([], Repo.all(Model.Product))
    refute match?([], Repo.all(Model.Shipper))
    refute match?([], Repo.all(Model.Supplier))
  end
end
