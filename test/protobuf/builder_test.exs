defmodule Protobuf.BuilderTest do
  use ExUnit.Case, async: true

  alias TestMsg.{Foo, Foo2, Link}
  alias TestMsg.Ext.DualUseCase

  test "new/2 uses default values for proto3" do
    assert Foo.new().a == 0
    assert Foo.new().c == ""
    assert Foo.new().e == nil
  end

  test "new/2 use nil for proto2" do
    assert Foo2.new().a == nil
    assert Foo2.new().c == nil
    assert Foo2.new().e == nil
  end

  test "works for circular reference" do
    assert TestMsg.Parent.new().child == nil
  end

  test "new/2 build embedded messages" do
    assert Foo.new(e: %{a: 1}).e == Foo.Bar.new(a: 1)
    assert Foo.new(h: [%{a: 1}]).h == [Foo.Bar.new(a: 1)]
  end

  test "new/2 build nested embedded messages" do
    link = Link.new(child: Link.new(child: Link.new(child: Link.new(value: 2))))
    assert Link.new(child: %{child: %{child: %{value: 2}}}) == link
  end

  test "new/2 doesn't build embedded messages for nil & map" do
    assert Foo.new(e: nil).e == nil
    assert Foo.new(%{}).e == nil
    assert Foo.new(l: %{"k" => 1}).l == %{"k" => 1}
  end

  test "new/2 raises an error for non-list repeated embedded msgs" do
    assert_raise Protocol.UndefinedError,
                 ~r/protocol Enumerable not implemented for %TestMsg.Foo.Bar/,
                 fn ->
                   Foo.new(h: Foo.Bar.new())
                 end
  end

  test "new/2 doesn't process struct" do
    msg = %Foo{}
    assert msg == Foo.new(msg)
  end

  test "new!/2 raises for fields that don't exist in the schema" do
    assert_raise KeyError, fn ->
      Foo.new!(nonexisting_field: "foo")
    end
  end

  test "new!/2 raises for non matched strct" do
    assert_raise ArgumentError, fn ->
      Foo.new!(Foo2.new())
    end
  end

  test "new/2 build correct message for non matched strct" do
    foo = Foo.new(Foo2.new(non_matched: 1))

    assert_raise Protobuf.EncodeError, fn ->
      Foo.encode(foo)
    end
  end

  test "new/2 correct defaults for custom_field_options" do
    assert %DualUseCase{a: nil, b: nil} == DualUseCase.new()
  end

  test "new/2 build for custom_field_options" do
    assert %DualUseCase{a: "s1", b: nil} == DualUseCase.new(a: "s1")
  end

  test "new/2 build for custom_field_options, bad value" do
    assert_raise Protocol.UndefinedError,
      fn -> DualUseCase.new(a: "s1", b: "s2") end
  end

  test "new/2 build for custom_field_options shape checks" do
    assert_raise RuntimeError,
      "When extype option is present, new expects unwrapped value, not struct.",
      fn -> DualUseCase.new!(a: %Google.Protobuf.StringValue{value: "s1"}) end
  end

  test "new/2 build for custom_field_options doesn't type check" do
    # Should be string
    assert %DualUseCase{a: 1} = DualUseCase.new!(a: 1)
  end
end
