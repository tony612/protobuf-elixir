defmodule Protobuf.Protoc.GeneratorTest do
  use ExUnit.Case, async: true

  alias Protobuf.Protoc.{Generator, Context}

  test "generate/2 works" do
    ctx = %Context{global_type_mapping: %{"name.proto" => %{}}}
    desc = Google.Protobuf.FileDescriptorProto.new(name: "name.proto")

    assert Generator.generate(ctx, desc) ==
             Google.Protobuf.Compiler.CodeGeneratorResponse.File.new(
               name: "name.pb.ex",
               content: ""
             )
  end

  test "generate/2 uses the package prefix" do
    ctx = %Context{
      package_prefix: "myapp",
      global_type_mapping: %{
        "name.proto" => %{".myapp.Foo" => %{type_name: "Myapp.Foo"}}
      }
    }

    desc =
      Google.Protobuf.FileDescriptorProto.new(
        name: "name.proto",
        message_type: [Google.Protobuf.DescriptorProto.new(name: "Foo")]
      )

    file = Generator.generate(ctx, desc)
    assert file.content =~ "defmodule Myapp.Foo do\n"
  end

  test "generate/2 uses the package prefix when descriptor has package" do
    ctx = %Context{
      package_prefix: "myapp.proto",
      global_type_mapping: %{
        "name.proto" => %{".myapp.proto.lib.Foo" => %{type_name: "Myapp.Proto.Lib.Foo"}}
      }
    }

    desc =
      Google.Protobuf.FileDescriptorProto.new(
        name: "name.proto",
        package: "lib",
        message_type: [Google.Protobuf.DescriptorProto.new(name: "Foo")]
      )

    file = Generator.generate(ctx, desc)
    assert file.content =~ "defmodule Myapp.Proto.Lib.Foo do\n"
  end
end
