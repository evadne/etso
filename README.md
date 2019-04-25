# Etso: An ETS Adapter for Ecto

Etso is an [ETS](http://erlang.org/doc/man/ets.html) adapter, allowing you to use [Ecto](https://hexdocs.pm/ecto/Ecto.html) schemas with ETS tables.

Within this library, a bare-bones Ecto Adapter is provided. The Adapter transparently spins up ETS tables for each Ecto Repo and Schema combination. The tables are publicly accessible to enable concurrency, and tracked by reference to ensure encapsulation. Each ETS table is spun up by a dedicated Table Server under a shared Dynamic Supervisor.

For a detailed look as to what is available, check out [Northwind Repo Test](./test/northwind/repo_test.exs).

Key highlights of this library are:

- It transparently handles translations between `Ecto.Schema` structs and ETS tuples.
- It knows how to form ETS Match Specifications for simple queries.

Key points to consider when adopting this library are:

- It is suitable for rapid retrieval of simply formatted data, for example presets that do not change frequently.
- It is not suitable for use as a full-fledged data layer unless your requirements are simple.

The following features are working:

- Basic query scenarios (C / R / U / D): insert all, insert one, get by ID, where, delete by ID.
- Selects
- Assocs
- Preloads

The following features, for example, are missing:

- Aggregates (dynamic / static)
- Joins
- Windows
- Transactions
- Migrations
- Locking
