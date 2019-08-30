defmodule Northwind.Repo do
  @otp_app Mix.Project.config()[:app]
  use Ecto.Repo, otp_app: @otp_app, adapter: Etso.Adapter
end
