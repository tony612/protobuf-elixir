defmodule Protobuf.Application do
  use Application

  @moduledoc """
  When extensions feature is enabled, all modules are scanned to fetch
  runtime information for extensions, see `Protobuf.Extension` for details.

  No children are created now.
  """

  @doc false
  def start(_type, _args) do
    Protobuf.Extension.cal_extensions(get_all_modules())

    Supervisor.start_link(_children = [], strategy: :one_for_one)
  end

  defp get_all_modules do
    case Application.get_env(:protobuf, :extensions) do
      :enabled ->
        case :code.get_mode() do
          :embedded ->
            :erlang.loaded()

          :interactive ->
            Enum.flat_map(Application.loaded_applications(), fn {app, _desc, _vsn} ->
              {:ok, modules} = :application.get_key(app, :modules)
              modules
            end)
        end

      _disabled ->
        # Extensions in Protobuf are required for generating code
        {:ok, mods} = :application.get_key(:protobuf, :modules)
        mods
    end
  end
end
