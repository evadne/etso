defmodule Etso.Adapter.Behaviour.Storage do
  @moduledoc false
  @behaviour Ecto.Adapter.Storage
  def storage_status(_options), do: :up
  def storage_up(_options), do: :ok
  def storage_down(_options), do: :ok
end
