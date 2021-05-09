defmodule Etso.NotImplementedException do
  defexception message: "Transactions are not implemented in Etso - rolling back does not work"
end
