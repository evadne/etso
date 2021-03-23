defmodule ETS.TableSorterTest do
  use ExUnit.Case

  describe "sort/2" do
    test "sort ets_objects" do
      query = dummy_query()
      ets_objects = dummy_ets_objects()

      [object1, object2, object3, object4, object5] = ets_objects

      [result1, result2, result3, result4, result5] =
        Etso.ETS.TableSorter.sort(ets_objects, query)

      assert object1 == result1
      assert object2 == result2
      assert object3 == result4
      assert object4 == result3
      assert object5 == result5
    end
  end

  def dummy_query() do
    %Ecto.Query{
      select: %Ecto.Query.SelectExpr{
        fields: [
          {{:., [], [{:&, [], [0]}, :order_id]}, [], []},
          {{:., [], [{:&, [], [0]}, :customer_id]}, [], []},
          {{:., [], [{:&, [], [0]}, :employee_id]}, [], []},
          {{:., [], [{:&, [], [0]}, :freight]}, [], []},
          {{:., [], [{:&, [], [0]}, :order_date]}, [], []},
          {{:., [], [{:&, [], [0]}, :required_date]}, [], []},
          {{:., [], [{:&, [], [0]}, :ship_name]}, [], []},
          {{:., [], [{:&, [], [0]}, :ship_via]}, [], []},
          {{:., [], [{:&, [], [0]}, :shipped_date]}, [], []},
          {{:., [], [{:&, [], [0]}, :ship_address]}, [], []},
          {{:., [], [{:&, [], [0]}, :details]}, [], []},
          {{:., [type: :integer], [{:&, [], [0]}, :ship_via]}, [], []}
        ]
      },
      order_bys: [
        %Ecto.Query.QueryExpr{
          expr: [asc: {{:., [], [{:&, [], [0]}, :ship_via]}, [], []}]
        }
      ]
    }
  end

  def dummy_ets_objects() do
    [
      [
        10309,
        "HUNGO",
        3,
        47.3,
        ~D[1996-09-19],
        ~D[1996-10-17],
        "Hungry Owl All-Night Grocers",
        1,
        ~D[1996-10-23],
        %{
          city: "Cork",
          country: "Ireland",
          phone: nil,
          postal_code: nil,
          region: "Co. Cork",
          street: "8 Johnstown Road"
        },
        [
          %{discount: 0.0, product_id: nil, quantity: 20, unit_price: nil},
          %{discount: 0.0, product_id: nil, quantity: 30, unit_price: nil},
          %{discount: 0.0, product_id: nil, quantity: 2, unit_price: nil},
          %{discount: 0.0, product_id: nil, quantity: 20, unit_price: nil},
          %{discount: 0.0, product_id: nil, quantity: 3, unit_price: nil}
        ],
        1
      ],
      [
        10269,
        "WHITC",
        5,
        4.56,
        ~D[1996-07-31],
        ~D[1996-08-14],
        "White Clover Markets",
        1,
        ~D[1996-08-09],
        %{
          city: "Seattle",
          country: "USA",
          phone: nil,
          postal_code: "98124",
          region: "WA",
          street: "1029 - 12th Ave. S."
        },
        [
          %{discount: 0.05, product_id: nil, quantity: 60, unit_price: nil},
          %{discount: 0.05, product_id: nil, quantity: 20, unit_price: nil}
        ],
        1
      ],
      [
        10677,
        "ANTON",
        1,
        4.03,
        ~D[1997-09-22],
        ~D[1997-10-20],
        "Antonio Moreno Taquería",
        3,
        ~D[1997-09-26],
        %{
          city: "México D.F.",
          country: "Mexico",
          phone: nil,
          postal_code: "5023",
          region: nil,
          street: "Mataderos  2312"
        },
        [
          %{discount: 0.15, product_id: nil, quantity: 30, unit_price: nil},
          %{discount: 0.15, product_id: nil, quantity: 8, unit_price: nil}
        ],
        3
      ],
      [
        10301,
        "WANDK",
        8,
        45.08,
        ~D[1996-09-09],
        ~D[1996-10-07],
        "Die Wandernde Kuh",
        2,
        ~D[1996-09-17],
        %{
          city: "Stuttgart",
          country: "Germany",
          phone: nil,
          postal_code: "70563",
          region: nil,
          street: "Adenauerallee 900"
        },
        [
          %{discount: 0.0, product_id: nil, quantity: 10, unit_price: nil},
          %{discount: 0.0, product_id: nil, quantity: 20, unit_price: nil}
        ],
        2
      ],
      [
        10542,
        "KOENE",
        1,
        10.95,
        ~D[1997-05-20],
        ~D[1997-06-17],
        "Königlich Essen",
        3,
        ~D[1997-05-26],
        %{
          city: "Brandenburg",
          country: "Germany",
          phone: nil,
          postal_code: "14776",
          region: nil,
          street: "Maubelstr. 90"
        },
        [
          %{discount: 0.05, product_id: nil, quantity: 15, unit_price: nil},
          %{discount: 0.05, product_id: nil, quantity: 24, unit_price: nil}
        ],
        3
      ]
    ]
  end
end
