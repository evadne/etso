defmodule Etso.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [{Registry, keys: :unique, name: Etso.Registry}]
    options = [strategy: :one_for_one, name: Etso.Supervisor]
    Supervisor.start_link(children, options)
  end
end
