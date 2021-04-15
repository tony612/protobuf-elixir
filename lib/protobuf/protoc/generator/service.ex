defmodule Protobuf.Protoc.Generator.Service do
  @moduledoc false
  alias Protobuf.Protoc.Generator.Util

  defp with_service_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [6, index]}
  end

  defp with_service_method_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [2, index]}
  end

  def generate_list(ctx, descs) do
    if Enum.member?(ctx.plugins, "grpc") do
      descs
      |> Enum.with_index()
      |> Enum.map(fn {desc, index} -> generate(with_service_path(ctx, index), desc) end)
    else
      []
    end
  end

  def generate(ctx, desc) do
    # service can't be nested
    mod_name = Util.mod_name(ctx, [Util.trans_name(desc.name)])
    name = Util.attach_raw_pkg(desc.name, ctx.package)
    methods = get_methods(ctx, desc.method)
    generate_desc = if ctx.gen_descriptors?, do: desc, else: nil

    docs =
      Util.moduledoc_str(
        ctx,
        methods |> Enum.all?(fn m -> String.length(String.trim(m[:docs])) end)
      )

    Protobuf.Protoc.Template.service(mod_name, name, methods, generate_desc, docs)
  end

  defp get_methods(ctx, descs) do
    descs
    |> Enum.with_index()
    |> Enum.map(fn {desc, index} ->
      get_service_method(with_service_method_path(ctx, index), desc)
    end)
  end

  defp get_service_method(ctx, method) do
    %{
      name: method.name,
      handler_name: Util.to_grpc_handler_func_name(method.name),
      input:
        service_arg(Util.type_from_type_name(ctx, method.input_type), method.client_streaming),
      output:
        service_arg(Util.type_from_type_name(ctx, method.output_type), method.server_streaming),
      docs: Util.fmt_doc_str(Util.find_location(ctx))
    }
  end

  defp service_arg(type, true), do: "stream(#{type})"
  defp service_arg(type, _), do: type
end
