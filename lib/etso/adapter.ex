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

  alias Etso.Adapter.TableRegistry

  @behaviour Ecto.Adapter
  @behaviour Ecto.Adapter.Schema
  @behaviour Ecto.Adapter.Queryable

  defmacro __before_compile__(_opts), do: :ok

  @doc false
  def ensure_all_started(_config, _type), do: {:ok, []}

  @doc false
  def init(config) do
    {:ok, repo} = Keyword.fetch(config, :repo)
    child_spec = __MODULE__.Supervisor.child_spec(repo)
    adapter_meta = %__MODULE__.Meta{repo: repo}
    {:ok, child_spec, Map.from_struct(adapter_meta)}
  end

  @doc false
  def checkout(_, _, fun), do: fun.()

  @doc false
  def checked_out?(_), do: false

  @doc false
  def loaders(:binary_id, type), do: [Ecto.UUID, type]
  def loaders(:embed_id, type), do: [Ecto.UUID, type]
  def loaders(_, type), do: [type]

  @doc false
  def dumpers(:binary_id, type), do: [type, Ecto.UUID]
  def dumpers(:embed_id, type), do: [type, Ecto.UUID]
  def dumpers(:map, type), do: [type, Etso.Ecto.MapType]
  def dumpers(_, type), do: [type]

  @doc """
  Delete all data from the tables.
  """
  @spec flush_tables(module()) :: :ok
  def flush_tables(repo) do
    repo
    |> TableRegistry.active_tables()
    |> Enum.each(& :ets.delete_all_objects(&1) == true)
  end

  for module <- [__MODULE__.Behaviour.Schema, __MODULE__.Behaviour.Queryable] do
    for {name, arity} <- module.__info__(:functions) do
      args = Enum.map(1..arity, &{:"arg_#{&1}", [], Elixir})

      @doc false
      def unquote(name)(unquote_splicing(args)) do
        unquote(module).unquote(name)(unquote_splicing(args))
      end
    end
  end
end
