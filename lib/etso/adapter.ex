defmodule Etso.Adapter do
  @moduledoc """
  Used as an Adapter in Repo modules, which transparently spins up one ETS table for each Schema
  used with the Repo, namespaced to the Repo to allow concurrent running of multiple Repositories.

  The Etso Adapter implements the `Ecto.Adapter.Schema` and `Ecto.Adapter.Queryable` behaviours.

  To use the Etso Adapter in your application, define a Repo like this:

      defmodule MyApp.Repo do
        @otp_app Mix.Project.config()[:app]
        use Ecto.Repo, otp_app: @otp_app, adapter: Etso.Adapter
      end
  """

  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Queryable
  @behaviour Ecto.Adapter.Schema
  @behaviour Ecto.Adapter.Storage

  @impl Ecto.Adapter
  defmacro __before_compile__(_opts), do: :ok

  @doc false
  @impl Ecto.Adapter
  def ensure_all_started(_config, _type), do: {:ok, []}

  @doc false
  @impl Ecto.Adapter
  def init(config) do
    {:ok, repo} = Keyword.fetch(config, :repo)
    child_spec = __MODULE__.Supervisor.child_spec(repo)
    adapter_meta = %__MODULE__.Meta{repo: repo}
    {:ok, child_spec, adapter_meta}
  end

  @doc false
  @impl Ecto.Adapter
  def checkout(_, _, fun), do: fun.()

  @doc false
  @impl Ecto.Adapter
  def checked_out?(_), do: false

  @doc false
  @impl Ecto.Adapter
  def loaders(:binary_id, type), do: [Ecto.UUID, type]
  def loaders(:embed_id, type), do: [Ecto.UUID, type]
  def loaders(_, type), do: [type]

  @doc false
  @impl Ecto.Adapter
  def dumpers(:binary_id, type), do: [type, Ecto.UUID]
  def dumpers(:embed_id, type), do: [type, Ecto.UUID]
  def dumpers(_, type), do: [type]

  for {implementation_module, behaviour_module} <- [
        {__MODULE__.Behaviour.Schema, Ecto.Adapter.Schema},
        {__MODULE__.Behaviour.Queryable, Ecto.Adapter.Queryable},
        {__MODULE__.Behaviour.Storage, Ecto.Adapter.Storage}
      ] do
    for {name, arity} <- implementation_module.__info__(:functions) do
      args = Enum.map(1..arity, &{:"arg_#{&1}", [], Elixir})

      @doc false
      @impl behaviour_module
      def unquote(name)(unquote_splicing(args)) do
        unquote(implementation_module).unquote(name)(unquote_splicing(args))
      end
    end
  end
end
