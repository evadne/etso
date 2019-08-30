defmodule Etso.MixProject do
  use Mix.Project

  def project do
    [
      app: :etso,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Etso",
      source_url: "https://github.com/evadne/etso"
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ecto, "~> 3.0.1"},
      {:jason, "~> 1.1", only: [:test], runtime: false}
    ]
  end

  defp description, do: "An ETS adapter for Ecto"

  defp package do
    [
      maintainers: ["Evadne Wu"],
      files: package_files(),
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/evadne/etso"}
    ]
  end

  defp package_files do
    ~w(
      lib/etso/*
      .formatter.exs
      mix.exs
      README*
    )
  end
end
