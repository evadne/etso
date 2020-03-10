defmodule Etso.Adapter.Meta do
  @moduledoc false

  @type t :: %__MODULE__{
          repo: Ecto.Repo.t(),
          persist_to_dets: boolean(),
          dets_folder: nil | String.t()
        }
  @enforce_keys ~w(repo persist_to_dets dets_folder)a
  defstruct repo: nil, persist_to_dets: false, dets_folder: nil

  def validate_dets_folder!(nil), do: nil

  def validate_dets_folder!(dets_folder) do
    with true <- File.exists?(dets_folder),
         true <- File.dir?(dets_folder) do
      dets_folder
    else
      _ -> raise "dets_folder config option is not a valid directory path"
    end
  end
end
