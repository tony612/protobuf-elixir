defmodule Protobuf.Application do
  use Application

  @moduledoc """
  When extensions feature is enabled, all modules are scanned to fetch
  runtime information for extensions, see `Protobuf.Extension` for details.

  No children are created now.
  """

  @doc false
  @impl true
  def start(_type, _args) do
    if Application.get_env(:protobuf, :extensions, :disabled) == :enabled do
      mods = get_all_modules()
      Protobuf.Extension.cal_extensions(mods)
    else
      # Extensions in Protobuf should always be calculated for generating code
      {:ok, mods} = :application.get_key(:protobuf, :modules)
      Protobuf.Extension.cal_extensions(mods)
    end

    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @impl true
  def stop(_state) do
    Protobuf.Extension.unload_extensions()
    :ok
  end

  defp get_all_modules() do
    case :code.get_mode() do
      :embedded ->
        :erlang.loaded()

      :interactive ->
        for {app, _, _} <- Application.loaded_applications() do
          {:ok, modules} = :application.get_key(app, :modules)
          modules
        end
        |> Enum.concat()
    end
  end
end
