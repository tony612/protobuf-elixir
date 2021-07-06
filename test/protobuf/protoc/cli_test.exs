defmodule Protobuf.Protoc.CLITest do
  use ExUnit.Case, async: true

  import Protobuf.Protoc.CLI

  alias Protobuf.Protoc.Context
  alias Google.Protobuf.FileDescriptorProto
  alias Google.Protobuf.DescriptorProto
  alias Google.Protobuf.EnumDescriptorProto

  test "parse_params/2 parse plugins" do
    ctx = %Context{}
    ctx = parse_params(ctx, "plugins=grpc,gen_descriptors=true,package_prefix=elixir.protobuf")

    assert ctx == %Context{
             plugins: ["grpc"],
             gen_descriptors?: true,
             package_prefix: "elixir.protobuf"
           }
  end

  test "find_types/2 returns multiple files" do
    ctx = %Context{}
    descs = [FileDescriptorProto.new(name: "file1"), FileDescriptorProto.new(name: "file2")]
    assert %{global_type_mapping: %{"file1" => %{}, "file2" => %{}}} = find_types(ctx, descs)
  end

  test "find_types_in_proto/1 merge message and enum" do
    desc =
      FileDescriptorProto.new(
        name: "file1",
        package: "pkg",
        message_type: [DescriptorProto.new(name: "Msg")],
        enum_type: [EnumDescriptorProto.new(name: "Enum")]
      )

    assert %{".pkg.Msg" => %{type_name: "Pkg.Msg"}, ".pkg.Enum" => %{type_name: "Pkg.Enum"}} =
             find_types_in_proto(%Context{}, desc)
  end

  test "find_types_in_proto/1 have nested message types" do
    desc =
      FileDescriptorProto.new(
        name: "file1",
        package: "pkg",
        message_type: [
          DescriptorProto.new(
            name: "Msg",
            nested_type: [DescriptorProto.new(name: "NestedMsg")],
            enum_type: [EnumDescriptorProto.new(name: "NestedEnumMsg")]
          )
        ]
      )

    assert %{
             ".pkg.Msg" => %{type_name: "Pkg.Msg"},
             ".pkg.Msg.NestedMsg" => %{type_name: "Pkg.Msg.NestedMsg"},
             ".pkg.Msg.NestedEnumMsg" => %{type_name: "Pkg.Msg.NestedEnumMsg"}
           } = find_types_in_proto(%Context{}, desc)
  end

  test "find_types_in_proto/1 have deeper nested message types" do
    desc =
      FileDescriptorProto.new(
        name: "file1",
        package: "pkg",
        message_type: [
          DescriptorProto.new(
            name: "Msg",
            nested_type: [
              DescriptorProto.new(
                name: "NestedMsg",
                nested_type: [DescriptorProto.new(name: "NestedMsg2")]
              )
            ]
          )
        ]
      )

    assert %{
             ".pkg.Msg" => %{type_name: "Pkg.Msg"},
             ".pkg.Msg.NestedMsg" => %{type_name: "Pkg.Msg.NestedMsg"},
             ".pkg.Msg.NestedMsg.NestedMsg2" => %{type_name: "Pkg.Msg.NestedMsg.NestedMsg2"}
           } = find_types_in_proto(%Context{}, desc)
  end

  test "find_types_in_proto/1 supports elixir_module_prefix" do
    opts = Google.Protobuf.FileOptions.new()
    custom_opts = Elixirpb.FileOptions.new(module_prefix: "FooBar.Prefix")

    opts =
      Google.Protobuf.FileOptions.put_extension(opts, Elixirpb.PbExtension, :file, custom_opts)

    desc =
      FileDescriptorProto.new(
        name: "file1",
        package: "pkg",
        message_type: [DescriptorProto.new(name: "Msg")],
        enum_type: [EnumDescriptorProto.new(name: "Enum")],
        options: opts
      )

    assert %{
             ".pkg.Msg" => %{type_name: "FooBar.Prefix.Msg"},
             ".pkg.Enum" => %{type_name: "FooBar.Prefix.Enum"}
           } = find_types_in_proto(%Context{}, desc)
  end
end
