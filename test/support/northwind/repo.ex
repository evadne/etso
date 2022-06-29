defmodule Northwind.Repo do
  @otp_app Mix.Project.config()[:app]
  use Ecto.Repo, otp_app: @otp_app, adapter: Etso.Adapter

  def with_dynamic_repo(name, callback_fun) when is_atom(name) do
    with_dynamic_repo([name: name], callback_fun)
  end

  def with_dynamic_repo(options, callback_fun) when is_list(options) do
    default_dynamic_repo = get_dynamic_repo()
    start_opts = Keyword.merge([name: nil], options)
    {:ok, repo} = __MODULE__.start_link(start_opts)

    try do
      __MODULE__.put_dynamic_repo(repo)
      callback_fun.()
    after
      __MODULE__.put_dynamic_repo(default_dynamic_repo)
      Supervisor.stop(repo)
    end
  end
end
