defmodule Etso do
  @moduledoc """
  Top-level module for Etso.
  """

  @type repo :: Ecto.Repo.t()
  @type schema :: module()
  @type table :: :ets.tab()
end
