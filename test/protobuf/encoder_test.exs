defmodule Protobuf.EncoderTest do
  use ExUnit.Case, async: true

  alias Protobuf.Encoder

  test "encodes one simple field" do
    bin = Encoder.encode(TestMsg.Foo.new(a: 42))
    assert bin == <<8, 42>>
  end

  test "encodes full fields" do
    bin = <<8, 42, 17, 100, 0, 0, 0, 0, 0, 0, 0, 26, 3, 115, 116, 114, 45, 0, 0, 247, 66>>
    res = Encoder.encode(TestMsg.Foo.new(a: 42, b: 100, c: "str", d: 123.5))
    assert res == bin
  end

  test "skips a field with default value" do
    bin = <<8, 42, 26, 3, 115, 116, 114, 45, 0, 0, 247, 66>>
    res = Encoder.encode(TestMsg.Foo.new(a: 42, c: "str", d: 123.5))
    assert res == bin
  end

  test "skips a field without default value" do
    bin = <<8, 42, 17, 100, 0, 0, 0, 0, 0, 0, 0, 45, 0, 0, 247, 66>>
    res = Encoder.encode(TestMsg.Foo.new(a: 42, b: 100, d: 123.5))
    assert res == bin
  end

  test "encodes embedded message" do
    bin = Encoder.encode(TestMsg.Foo.new(a: 42, e: %TestMsg.Foo.Bar{a: 12, b: "abc"}, f: 13))
    assert bin == <<8, 42, 50, 7, 8, 12, 18, 3, 97, 98, 99, 56, 13>>
  end

  test "encodes empty embedded message" do
    bin = Encoder.encode(TestMsg.Foo.new(a: 42, e: TestMsg.Foo.Bar.new()))
    assert bin == <<8, 42, 50, 0>>
  end

  test "encodes repeated non-packed varint fields" do
    bin = Encoder.encode(TestMsg.Foo.new(a: 123, g: [12, 13, 14]))
    assert bin == <<8, 123, 64, 12, 64, 13, 64, 14>>
  end

  test "encodes repeated varint fields with all 0" do
    bin = Encoder.encode(TestMsg.Foo.new(g: [0, 0, 0]))
    assert bin == <<64, 0, 64, 0, 64, 0>>
  end

  test "encodes repeated embedded fields" do
    bin = <<74, 7, 8, 12, 18, 3, 97, 98, 99, 74, 2, 8, 13>>

    res =
      Encoder.encode(
        TestMsg.Foo.new(h: [%TestMsg.Foo.Bar{a: 12, b: "abc"}, TestMsg.Foo.Bar.new(a: 13)])
      )

    assert res == bin
  end

  test "encodes repeated embedded fields with all empty struct" do
    bin = Encoder.encode(TestMsg.Foo.new(h: [TestMsg.Foo.Bar.new(), TestMsg.Foo.Bar.new()]))
    assert bin == <<74, 0, 74, 0>>
  end

  test "encodes packed fields" do
    bin = Encoder.encode(TestMsg.Foo.new(i: [12, 13, 14]))
    assert bin == <<82, 3, 12, 13, 14>>
  end

  test "encodes packed fields with all 0" do
    bin = Encoder.encode(TestMsg.Foo.new(i: [0, 0, 0]))
    assert bin == <<82, 3, 0, 0, 0>>
  end

  test "encodes enum type" do
    bin = Encoder.encode(TestMsg.Foo.new(j: 2))
    assert bin == <<88, 2>>
    bin = Encoder.encode(TestMsg.Foo.new(j: :A))
    assert bin == <<88, 1>>
    bin = Encoder.encode(TestMsg.Foo.new(j: :B))
    assert bin == <<88, 2>>
  end

  test "encodes repeated enum fields using packed by default" do
    bin = Encoder.encode(TestMsg.Foo.new(o: [:A, :B]))
    assert bin == <<130, 1, 2, 1, 2>>
  end

  test "encodes unknown enum type" do
    bin = Encoder.encode(TestMsg.Foo.new(j: 3))
    assert bin == <<88, 3>>
  end

  test "encodes 0" do
    assert Encoder.encode(TestMsg.Foo.new(a: 0)) == <<>>
  end

  test "encodes empty string" do
    assert Encoder.encode(TestMsg.Foo.new(c: "")) == <<>>
  end

  test "encodes bool" do
    assert Encoder.encode(TestMsg.Foo.new(k: false)) == <<>>
    assert Encoder.encode(TestMsg.Foo.new(k: true)) == <<96, 1>>
  end

  test "encode map type" do
    bin = <<106, 12, 10, 7, 102, 111, 111, 95, 107, 101, 121, 16, 213, 1>>
    struct = TestMsg.Foo.new(l: %{"foo_key" => 213})
    assert Encoder.encode(struct) == bin
  end

  test "encodes 0 for proto2" do
    assert Encoder.encode(TestMsg.Foo2.new(a: 0)) == <<8, 0, 17, 5, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "encodes [] for proto2" do
    assert Encoder.encode(TestMsg.Foo2.new(a: 0, g: [])) == <<8, 0, 17, 5, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "encodes %{} for proto2" do
    assert Encoder.encode(TestMsg.Foo2.new(a: 0, l: %{})) == <<8, 0, 17, 5, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "encodes custom default message for proto2" do
    assert Encoder.encode(TestMsg.Foo2.new(a: 0, b: 0)) == <<8, 0, 17, 0, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "encodes oneof fields" do
    msg = TestMsg.Oneof.new(%{first: {:a, 42}, second: {:d, "abc"}, other: "other"})
    assert Encoder.encode(msg) == <<8, 42, 34, 3, 97, 98, 99, 42, 5, 111, 116, 104, 101, 114>>
    msg = TestMsg.Oneof.new(%{first: {:b, "abc"}, second: {:c, 123}, other: "other"})
    assert Encoder.encode(msg) == <<18, 3, 97, 98, 99, 24, 123, 42, 5, 111, 116, 104, 101, 114>>
  end

  test "encodes oneof fields zero values" do
    # proto2
    # int and string
    msg = TestMsg.Oneof.new(first: {:a, 0}, second: {:d, ""})
    assert Encoder.encode(msg) == <<8, 0, 34, 0>>
    msg = TestMsg.Oneof.new(first: {:b, ""}, second: {:c, 0})
    assert Encoder.encode(msg) == <<18, 0, 24, 0>>
    # enum
    msg = TestMsg.Oneof.new(first: {:e, :UNKNOWN})
    assert Encoder.encode(msg) == <<48, 0>>
    assert TestMsg.Oneof.decode(<<48, 0>>) == msg

    # proto3
    # int and string
    msg = TestMsg.OneofProto3.new(first: {:a, 0}, second: {:d, ""})
    assert Encoder.encode(msg) == <<8, 0, 34, 0>>
    assert TestMsg.OneofProto3.encode(msg) == <<8, 0, 34, 0>>
    msg = TestMsg.OneofProto3.new(first: {:b, ""}, second: {:c, 0})
    assert Encoder.encode(msg) == <<18, 0, 24, 0>>
    assert TestMsg.OneofProto3.encode(msg) == <<18, 0, 24, 0>>
    # enum
    msg = TestMsg.OneofProto3.new(first: {:e, :UNKNOWN})
    assert Encoder.encode(msg) == <<48, 0>>
    assert TestMsg.OneofProto3.decode(<<48, 0>>) == msg
  end

  test "encodes map with oneof" do
    msg = Google.Protobuf.Struct.new(fields: %{"valid" => %{kind: {:bool_value, true}}})
    bin = Google.Protobuf.Struct.encode(msg)

    assert Google.Protobuf.Struct.decode(bin) ==
             Google.Protobuf.Struct.new(
               fields: %{"valid" => %Google.Protobuf.Value{kind: {:bool_value, true}}}
             )
  end

  test "encodes default value for proto2" do
    # Includes required
    msg = TestMsg.Bar2.new(a: 0)
    assert Encoder.encode(msg) == <<8, 0>>

    # Excludes optionals at default value
    msg = TestMsg.Bar2.new(a: 0, b: 0)
    assert Encoder.encode(msg) == <<8, 0>>

    msg = TestMsg.Bar2.new(a: 0, b: 1)
    assert Encoder.encode(msg) == <<8, 0, 16, 1>>
  end

  test "encoding with custom field options" do
    msg = TestMsg.Ext.DualUseCase.new(a: "s1", b: Google.Protobuf.StringValue.new(value: "s2"))
    assert Encoder.encode(msg) == <<10, 4, 10, 2, 115, 49, 18, 4, 10, 2, 115, 50>>
  end

  test "encoding with custom field options, empty" do
    msg = TestMsg.Ext.DualUseCase.new(b: Google.Protobuf.StringValue.new(value: "s2"))
    assert Encoder.encode(msg) == <<18, 4, 10, 2, 115, 50>>
  end
end
