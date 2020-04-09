defmodule Protobuf.Protoc.Generator.UtilTest do
  use ExUnit.Case, async: true

  import Protobuf.Protoc.Generator.Util

  test "mod_name can handle nil prefix" do
    assert mod_name(%{module_prefix: nil}, ["Foo", "Bar"]) == "Foo.Bar"
  end

  test "mod_name can handle empty package" do
    assert mod_name(%{module_prefix: ""}, ["Foo", "Bar"]) == "Foo.Bar"
  end

  test "mod_name returns right name" do
    assert mod_name(%{module_prefix: "custom.prefix"}, ["Foo", "Bar"]) == "Custom.Prefix.Foo.Bar"
  end

  test "mod_name returns prefixed package name" do
    assert mod_name(%{package_prefix: "custom.prefix", package: "pkg", module_prefix: nil}, [
             "Foo",
             "Bar"
           ]) ==
             "Custom.Prefix.Pkg.Foo.Bar"
  end

  test "mod_name returns module prefix when  package prefix is present" do
    assert mod_name(
             %{module_prefix: "overrides", package_prefix: "custom.prefix", package: "pkg"},
             ["Foo", "Bar"]
           ) ==
             "Overrides.Foo.Bar"
  end
end
