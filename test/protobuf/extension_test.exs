defmodule Protobuf.ExtensionTest do
  use ExUnit.Case, async: true

  alias TestMsg.Ext

  test "extension persistent works" do
    assert Ext.PbExtension == :persistent_term.get({Protobuf.Extension, Ext.Foo1, 1047})
    assert Ext.PbExtension == :persistent_term.get({Protobuf.Extension, Ext.Foo1, 1048})
    assert Ext.PbExtension == :persistent_term.get({Protobuf.Extension, Ext.Foo1, 1049})
    assert Ext.PbExtension == :persistent_term.get({Protobuf.Extension, Ext.Foo2, 1047})
  end

  test "extension get/put work" do
    assert %{__pb_extensions__: %{{Ext.PbExtension, :foo} => "foo"}} =
             Ext.Foo1.put_extension(%{}, Ext.PbExtension, :foo, "foo")

    assert %{__pb_extensions__: %{{Ext.PbExtension, :bar} => "bar"}} =
             Ext.Foo2.put_extension(%{}, Ext.PbExtension, :bar, "bar")

    assert %{__pb_extensions__: %{{Ext.PbExtension, :"Parent.foo"} => "nested.foo"}} =
             Ext.Foo1.put_extension(%{}, Ext.PbExtension, :"Parent.foo", "nested.foo")
  end

  test "extension put not existed key" do
    assert_raise Protobuf.ExtensionNotFound, fn ->
      Ext.Foo1.put_extension(%{}, Ext.PbExtension, :not_exist, "foo")
    end
  end

  test "simple types work" do
    bin = <<186, 65, 3, 97, 98, 99>>
    msg = Ext.Foo2.new()
    msg = Ext.Foo2.put_extension(msg, Ext.PbExtension, :bar, "abc")
    assert bin == Ext.Foo2.encode(msg)

    msg = Ext.Foo2.decode(bin)
    assert %{__pb_extensions__: %{{Ext.PbExtension, :bar} => "abc"}} = msg
    assert "abc" == Ext.Foo2.get_extension(msg, Ext.PbExtension, :bar)
  end

  test "nested types work" do
    bin = <<186, 65, 5, 10, 3, 97, 98, 99>>
    msg = Ext.Foo1.new()
    ext_msg = Ext.Options.new(a: "abc")
    msg = Ext.Foo1.put_extension(msg, Ext.PbExtension, :foo, ext_msg)
    assert bin == Ext.Foo2.encode(msg)

    msg = Ext.Foo1.decode(bin)
    assert %{__pb_extensions__: %{{Ext.PbExtension, :foo} => %Ext.Options{a: "abc"}}} = msg
    assert %Ext.Options{a: "abc"} == Ext.Foo2.get_extension(msg, Ext.PbExtension, :foo)
  end

  test "enum types work" do
    bin = <<192, 65, 2>>
    msg = Ext.Foo1.new()
    msg = Ext.Foo1.put_extension(msg, Ext.PbExtension, :"Parent.foo", :B)
    assert bin == Ext.Foo1.encode(msg)

    msg = Ext.Foo1.decode(bin)
    assert %{__pb_extensions__: %{{Ext.PbExtension, :"Parent.foo"} => :B}} = msg
    assert :B == Ext.Foo1.get_extension(msg, Ext.PbExtension, :"Parent.foo")
  end
end
