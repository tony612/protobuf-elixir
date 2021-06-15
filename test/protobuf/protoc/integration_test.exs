defmodule Protobuf.Protoc.IntegrationTest do
  use ExUnit.Case, async: true
  @moduletag :integration

  test "encode and decode My.Test.Request" do
    entry = %My.Test.Reply.Entry{
      key_that_needs_1234camel_CasIng: 1,
      value: -12_345,
      _my_field_name_2: 21
    }

    reply = My.Test.Reply.new(found: [entry], compact_keys: [1, 2, 3])

    input =
      My.Test.Request.new(
        key: [123],
        hue: :GREEN,
        hat: :FEZ,
        deadline: 123.0,
        name_mapping: %{321 => "name"},
        msg_mapping: %{1234 => reply}
      )

    output = My.Test.Request.encode(input)
    assert My.Test.Request.__message_props__().field_props[14].map?
    assert My.Test.Request.__message_props__().field_props[15].map?
    assert My.Test.Request.NameMappingEntry.__message_props__().map?
    assert My.Test.Request.MsgMappingEntry.__message_props__().map?
    assert My.Test.Request.decode(output) == input
  end

  test "encode and decode My.Test.Communique(oneof)" do
    unions = [
      number: 42,
      name: "abc",
      temp_c: 1.2,
      height: 2.5,
      today: :MONDAY,
      maybe: true,
      delta: 123,
      msg: My.Test.Reply.new()
    ]

    Enum.each(unions, fn union ->
      input = %My.Test.Communique{union: union}
      output = My.Test.Communique.encode(input)
      assert My.Test.Communique.decode(output) == input
    end)
  end

  test "options" do
    assert %{deprecated?: true} = My.Test.Options.__message_props__().field_props[1]

    assert %{
             extensions: %{{Mypkg.PbExtension, :myopt_bool} => true}
           } = My.Test.Options.__message_props__().field_props[2]
  end

  test "extensions" do
    assert "hello" == Protobuf.Protoc.ExtTest.Foo.new(a: "hello").a
  end
end
