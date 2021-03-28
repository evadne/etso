defmodule Etso.Adapter.Behaviour.Transaction do
  @moduledoc false

  def in_transaction?(_) do
    # never in a transaction?
    false
  end

  def rollback(_, _) do
    # do nothing.
  end

  def transaction(_, _, func) do
    # just return the result of func
    {:ok, func.()}
  end
end
