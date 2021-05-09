defmodule Etso.Adapter.Behaviour.Transaction do
  @moduledoc false
  # in_transaction?/1 enables parallel preloading
  def in_transaction?(_), do: false

  #  no-op does nothing in ecto, this ensures rollback is not used
  def rollback(_, _), do: raise(Etso.NotImplementedException)

  # all repo calls seem to rely on this and if returning anything other than {:ok, value} lots of tests fail
  # https://hexdocs.pm/ecto/Ecto.Adapter.Transaction.html#c:transaction/3
  def transaction(_, _, func), do: {:ok, func.()}
end
