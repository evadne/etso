defmodule Etso.ETS.ObjectsSorterTest do
  use ExUnit.Case, async: true

  import Ecto.Query

  defmodule Item do
    use Ecto.Schema

    schema "items" do
      field :name, :string
      field :inserted_at, :utc_datetime_usec
    end
  end

  test "sorts ETS rows when query.order_bys uses Ecto 3.13 ByExpr" do
    query =
      from item in Item,
        select: {item.id, item.inserted_at},
        order_by: [desc: item.inserted_at]

    rows = [
      {1, ~U[2024-01-01 00:00:00Z]},
      {2, ~U[2024-01-03 00:00:00Z]},
      {3, ~U[2024-01-02 00:00:00Z]}
    ]

    assert Etso.ETS.ObjectsSorter.sort(rows, query) == [
             {2, ~U[2024-01-03 00:00:00Z]},
             {3, ~U[2024-01-02 00:00:00Z]},
             {1, ~U[2024-01-01 00:00:00Z]}
           ]
  end

  test "sorts tuple-backed ETS rows using compound order_by clauses" do
    query =
      from item in Item,
        select: {item.name, item.inserted_at},
        order_by: [desc: item.name, asc: item.inserted_at]

    rows = [
      {"alpha", ~U[2024-01-02 00:00:00Z]},
      {"beta", ~U[2024-01-01 00:00:00Z]},
      {"beta", ~U[2024-01-03 00:00:00Z]},
      {"alpha", ~U[2024-01-01 00:00:00Z]}
    ]

    assert Etso.ETS.ObjectsSorter.sort(rows, query) == [
             {"beta", ~U[2024-01-01 00:00:00Z]},
             {"beta", ~U[2024-01-03 00:00:00Z]},
             {"alpha", ~U[2024-01-01 00:00:00Z]},
             {"alpha", ~U[2024-01-02 00:00:00Z]}
           ]
  end

  test "breaks ties with the secondary ordering while preserving primary descending precedence" do
    query =
      from item in Item,
        order_by: [desc: item.name, asc: item.inserted_at]

    rows = [
      %Item{name: "Federal Shipping", inserted_at: ~U[2024-01-03 00:00:00Z]},
      %Item{name: "United Package", inserted_at: ~U[2024-01-02 00:00:00Z]},
      %Item{name: "United Package", inserted_at: ~U[2024-01-01 00:00:00Z]},
      %Item{name: "Speedy Express", inserted_at: ~U[2024-01-04 00:00:00Z]}
    ]

    assert Etso.ETS.ObjectsSorter.sort(rows, query) == [
             %Item{name: "United Package", inserted_at: ~U[2024-01-01 00:00:00Z]},
             %Item{name: "United Package", inserted_at: ~U[2024-01-02 00:00:00Z]},
             %Item{name: "Speedy Express", inserted_at: ~U[2024-01-04 00:00:00Z]},
             %Item{name: "Federal Shipping", inserted_at: ~U[2024-01-03 00:00:00Z]}
           ]
  end

  test "sorts schema structs when query has no explicit select projection" do
    query =
      from item in Item,
        order_by: [asc: item.name]

    rows = [
      %Item{name: "gamma", inserted_at: ~U[2024-01-03 00:00:00Z]},
      %Item{name: "alpha", inserted_at: ~U[2024-01-02 00:00:00Z]},
      %Item{name: "beta", inserted_at: ~U[2024-01-01 00:00:00Z]}
    ]

    assert Etso.ETS.ObjectsSorter.sort(rows, query) == [
             %Item{name: "alpha", inserted_at: ~U[2024-01-02 00:00:00Z]},
             %Item{name: "beta", inserted_at: ~U[2024-01-01 00:00:00Z]},
             %Item{name: "gamma", inserted_at: ~U[2024-01-03 00:00:00Z]}
           ]
  end
end
