defmodule Protobuf.DecoderTest do
  use ExUnit.Case, async: true

  alias Protobuf.Decoder

  test "decodes one simple field" do
    struct = Decoder.decode(<<8, 42>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(a: 42)
  end

  test "decodes full fields" do
    bin = <<8, 42, 17, 100, 0, 0, 0, 0, 0, 0, 0, 26, 3, 115, 116, 114, 45, 0, 0, 247, 66>>
    struct = Decoder.decode(bin, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(a: 42, b: 100, c: "str", d: 123.5)
  end

  test "skips a known fields" do
    bin = <<8, 42, 26, 3, 115, 116, 114, 45, 0, 0, 247, 66>>
    struct = Decoder.decode(bin, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(a: 42, c: "str", d: 123.5)
  end

  test "raises for wrong wire type" do
    assert_raise(Protobuf.DecodeError, ~r{wrong wire_type for a: got 1, want 0}, fn ->
      Decoder.decode(<<9, 42, 0, 0, 0, 0, 0, 0, 0>>, TestMsg.Foo)
    end)
  end

  test "raises for bad binaries" do
    assert_raise(Protobuf.DecodeError, ~r{cannot decode binary data}, fn ->
      Decoder.decode(<<0, 0, 0, 0, 0, 0, 0>>, TestMsg.Foo)
    end)
  end

  test "skips unknown varint fields" do
    struct = Decoder.decode(<<8, 42, 32, 100, 45, 0, 0, 247, 66>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(a: 42, d: 123.5)
  end

  test "skips unknown string fields" do
    struct = Decoder.decode(<<8, 42, 45, 0, 0, 247, 66>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(a: 42, d: 123.5)
  end

  test "decodes embedded message" do
    struct = Decoder.decode(<<8, 42, 50, 7, 8, 12, 18, 3, 97, 98, 99, 56, 13>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(a: 42, e: %TestMsg.Foo.Bar{a: 12, b: "abc"}, f: 13)
  end

  test "merges singular embedded messages for multiple fields" do
    # %{a: 12} + %{a: 21, b: "abc"}
    bin = <<50, 2, 8, 12, 50, 7, 8, 21, 18, 3, 97, 98, 99>>
    struct = Decoder.decode(bin, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(e: %TestMsg.Foo.Bar{a: 21, b: "abc"})
  end

  test "decodes repeated varint fields" do
    struct = Decoder.decode(<<64, 12, 8, 123, 64, 13, 64, 14>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(a: 123, g: [12, 13, 14])
  end

  test "decodes repeated embedded fields" do
    bin = <<74, 7, 8, 12, 18, 3, 97, 98, 99, 74, 2, 8, 13>>
    struct = Decoder.decode(bin, TestMsg.Foo)

    assert struct ==
             TestMsg.Foo.new(h: [%TestMsg.Foo.Bar{a: 12, b: "abc"}, TestMsg.Foo.Bar.new(a: 13)])
  end

  test "decodes packed fields" do
    struct = Decoder.decode(<<82, 2, 12, 13>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(i: [12, 13])
  end

  test "concat multiple packed fields" do
    struct = Decoder.decode(<<82, 2, 12, 13, 82, 2, 14, 15>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(i: [12, 13, 14, 15])
  end

  test "decodes enum type" do
    struct = Decoder.decode(<<88, 1>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(j: :A)
    struct = Decoder.decode(<<88, 2>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(j: :B)
  end

  test "decodes unknown enum type" do
    struct = Decoder.decode(<<88, 3>>, TestMsg.Foo)
    assert struct == TestMsg.Foo.new(j: 3)
  end

  test "decodes map type" do
    struct =
      Decoder.decode(
        <<106, 12, 10, 7, 102, 111, 111, 95, 107, 101, 121, 16, 213, 1>>,
        TestMsg.Foo
      )

    assert struct == TestMsg.Foo.new(l: %{"foo_key" => 213})
  end

  test "decodes 0 for proto2" do
    assert Decoder.decode(<<8, 0, 17, 5, 0, 0, 0, 0, 0, 0, 0>>, TestMsg.Foo2) ==
             TestMsg.Foo2.new(a: 0)
  end

  test "decodes [] for proto2" do
    assert Decoder.decode(<<8, 0, 17, 5, 0, 0, 0, 0, 0, 0, 0>>, TestMsg.Foo2) ==
             TestMsg.Foo2.new(a: 0, g: [])
  end

  test "decodes %{} for proto2" do
    assert Decoder.decode(<<8, 0, 17, 5, 0, 0, 0, 0, 0, 0, 0>>, TestMsg.Foo2) ==
             TestMsg.Foo2.new(a: 0, l: %{})
  end

  test "decodes custom default message for proto2" do
    assert Decoder.decode(<<8, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0>>, TestMsg.Foo2) ==
             TestMsg.Foo2.new(a: 0, b: 0)

    assert Decoder.decode(<<8, 0>>, TestMsg.Foo2) == TestMsg.Foo2.new(a: 0, b: 5)
  end

  test "oneof only sets oneof fields" do
    assert Decoder.decode(
             <<42, 5, 111, 116, 104, 101, 114, 8, 42, 34, 3, 97, 98, 99>>,
             TestMsg.Oneof
           ) == %TestMsg.Oneof{first: {:a, 42}, second: {:d, "abc"}, other: "other"}

    assert Decoder.decode(
             <<42, 5, 111, 116, 104, 101, 114, 18, 3, 97, 98, 99, 24, 123>>,
             TestMsg.Oneof
           ) == %TestMsg.Oneof{first: {:b, "abc"}, second: {:c, 123}, other: "other"}
  end

  test "oneof only sets oneof fields for zero values" do
    assert Decoder.decode(<<8, 0, 34, 0>>, TestMsg.Oneof) ==
             TestMsg.Oneof.new(first: {:a, 0}, second: {:d, ""})

    assert Decoder.decode(<<18, 0, 24, 0>>, TestMsg.Oneof) ==
             TestMsg.Oneof.new(first: {:b, ""}, second: {:c, 0})
  end

  test "decode with and without custom field options" do
    bin = <<10, 4, 10, 2, 115, 49, 18, 4, 10, 2, 115, 50>>

    assert Decoder.decode(bin, TestMsg.Ext.DualUseCase) ==
      TestMsg.Ext.DualUseCase.new(a: "s1", b: Google.Protobuf.StringValue.new(value: "s2"))

    assert Decoder.decode(bin, TestMsg.Ext.DualNonUse) ==
      TestMsg.Ext.DualNonUse.new(
        a: Google.Protobuf.StringValue.new(value: "s1"),
        b: Google.Protobuf.StringValue.new(value: "s2")
      )
  end

  test "decode with and without custom field options, empty" do
    bin = <<18, 4, 10, 2, 115, 50>>

    assert Decoder.decode(bin, TestMsg.Ext.DualUseCase) ==
      TestMsg.Ext.DualUseCase.new(a: nil, b: Google.Protobuf.StringValue.new(value: "s2"))

    assert Decoder.decode(bin, TestMsg.Ext.DualNonUse) ==
      TestMsg.Ext.DualNonUse.new(a: nil, b: Google.Protobuf.StringValue.new(value: "s2"))
  end
end
