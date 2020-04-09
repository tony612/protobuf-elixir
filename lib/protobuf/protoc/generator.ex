defmodule Protobuf.Protoc.Generator do
  @moduledoc false

  alias Protobuf.Protoc.Generator.Message, as: MessageGenerator
  alias Protobuf.Protoc.Generator.Enum, as: EnumGenerator
  alias Protobuf.Protoc.Generator.Service, as: ServiceGenerator
  alias Protobuf.Protoc.Generator.Extension, as: ExtensionGenerator

  @locals_without_parens [field: 2, field: 3, oneof: 2, rpc: 3, extend: 4, extensions: 1]

  def generate(ctx, desc) do
    name = new_file_name(desc.name)

    Google.Protobuf.Compiler.CodeGeneratorResponse.File.new(
      name: name,
      content: generate_content(ctx, desc)
    )
  end

  defp new_file_name(name) do
    String.replace_suffix(name, ".proto", ".pb.ex")
  end

  def generate_content(ctx, desc) do
    ctx = %{
      ctx
      | syntax: syntax(desc.syntax),
        package: desc.package || "",
        dep_type_mapping: get_dep_type_mapping(ctx, desc.dependency, desc.name)
    }

    ctx = Protobuf.Protoc.Context.cal_file_options(ctx, desc.options)

    {enums, msgs} = MessageGenerator.generate_list(ctx, desc.message_type)

    list =
      EnumGenerator.generate_list(ctx, desc.enum_type) ++
        enums ++ msgs ++ ServiceGenerator.generate_list(ctx, desc.service)

    nested_extensions =
      ExtensionGenerator.get_nested_extensions(ctx, desc.message_type)
      |> Enum.reverse()

    list = list ++ [ExtensionGenerator.generate(ctx, desc, nested_extensions)]

    list
    |> List.flatten()
    |> Enum.join("\n")
    |> format_code()
  end

  @doc false
  def get_dep_pkgs(%{pkg_mapping: mapping, package: pkg}, deps) do
    pkgs = deps |> Enum.map(fn dep -> mapping[dep] end)
    pkgs = if pkg && String.length(pkg) > 0, do: [pkg | pkgs], else: pkgs
    Enum.sort(pkgs, &(byte_size(&2) <= byte_size(&1)))
  end

  def get_dep_type_mapping(%{global_type_mapping: global_mapping}, deps, file_name) do
    mapping =
      Enum.reduce(deps, %{}, fn dep, acc ->
        Map.merge(acc, global_mapping[dep])
      end)

    Map.merge(mapping, global_mapping[file_name])
  end

  defp syntax("proto3"), do: :proto3
  defp syntax(_), do: :proto2

  def format_code(code) do
    formated =
      if Code.ensure_loaded?(Code) && function_exported?(Code, :format_string!, 2) do
        code
        |> Code.format_string!(locals_without_parens: @locals_without_parens)
        |> IO.iodata_to_binary()
      else
        code
      end

    if formated == "" do
      formated
    else
      formated <> "\n"
    end
  end
end
