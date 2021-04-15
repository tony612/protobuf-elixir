defmodule Protobuf.Protoc.Generator.EnumTest do
  use ExUnit.Case, async: true

  alias Protobuf.Protoc.Context
  alias Protobuf.Protoc.Generator.Enum, as: Generator

  test "generate/2 generates enum type messages" do
    ctx = %Context{package: ""}

    desc = %Google.Protobuf.EnumDescriptorProto{
      name: "EnumFoo",
      options: nil,
      value: [
        Google.Protobuf.EnumValueDescriptorProto.new(name: "A", number: 0),
        Google.Protobuf.EnumValueDescriptorProto.new(name: "B", number: 1)
      ]
    }

    msg = Generator.generate(ctx, desc)
    assert msg =~ "defmodule EnumFoo do\n"
    assert msg =~ "use Protobuf, enum: true\n"
    assert msg =~ "@type a :: :A\n"
    assert msg =~ "@type b :: :B\n"
    assert msg =~ "@type t :: integer | a() | b()\n"
    refute msg =~ "defstruct "
    assert msg =~ "field :A, 0\n\n  field :B, 1\n"
  end
end
