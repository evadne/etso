defmodule Etso do
  @moduledoc """
  Top-level module for Etso.
  """

  @type adapter_meta :: Etso.Adapter.Meta.t()
  @type schema :: module()
  @type table :: :ets.tab()
end
