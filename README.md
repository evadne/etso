# Etso

## Overview

Etso is an [ETS](http://erlang.org/doc/man/ets.html) adapter, allowing you to use [Ecto](https://hexdocs.pm/ecto/Ecto.html) schemas with ETS tables.

Within this library, a bare-bones Ecto Adapter is provided. The Adapter transparently spins up ETS tables for each Ecto Repo and Schema combination. The tables are publicly accessible to enable concurrency, and tracked by reference to ensure encapsulation. Each ETS table is spun up by a dedicated Table Server under a shared Dynamic Supervisor.

For a detailed look as to what is available, check out [Northwind Repo Test](https://github.com/evadne/etso/tree/master/test/northwind/repo_test.exs).

## Highlights & Benefits

Key highlights of this library are:

- It transparently handles translations between `Ecto.Schema` structs and ETS tuples.
- It knows how to form ETS Match Specifications for simple queries.

Key points to consider when adopting this library are:

- It is suitable for rapid retrieval of simply formatted data, for example presets that do not change frequently.
- It is not suitable for use as a full-fledged data layer unless your requirements are simple.

## Feature Coverage

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

## Installation

Using Etso is a two-step process. First, include it in your application’s dependencies:

    defp deps do
      [
        {:etso, "~> 0.1.0"}
      ]
    end

Afterwards, create a new [Ecto.Repo](https://hexdocs.pm/ecto/Ecto.Repo.html), which uses `Etso.Adapter`:

    defmodule MyApp.Repo do
      @otp_app Mix.Project.config()[:app]
      use Ecto.Repo, otp_app: @otp_app, adapter: Etso.Adapter
    end

Once this is done, you can use any struct against the Repo normally, as you would with any other Repo. Check out the [Northwind modules](https://github.com/evadne/etso/tree/master/test/support/northwind) for an example.

## Further Note

This repository is extracted from a prior project [ETS Playground](https://github.com/evadne/ets-playground), which was created to support my session at ElixirConf EU 2019, [*Leveraging ETS Effectively.*](https://speakerdeck.com/evadne/leveraging-ets-effectively)

## Acknowledgements

This project contains a copy of data obtained from the Northwind database, which is owned by Microsoft. It is included for demonstration and testing purposes only, and is excluded from the distribution. The Author thanks Microsoft Corporation for the inspiration.

The Author also wishes to thank the following individuals:

- [Wojtek Mach](https://github.com/wojtekmach), for the [inspiration](https://github.com/wojtekmach/ets_ecto) regarding creation of an Ecto adapter for ETS.

- [Steven Holdsworth](https://github.com/holsee), for initial concept proofing and refinement.

- [Igor Kopestenski](https://github.com/laymer), for initial reviews.

- [David Schainker](https://github.com/schainks), for initial reviews, and for finding uses for this library.
