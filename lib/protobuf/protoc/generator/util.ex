defmodule Protobuf.Protoc.Generator.Util do
  @moduledoc false
  def trans_name(name) do
    Macro.camelize(name)
  end

  def join_name(list) do
    Enum.join(list, ".")
  end

  def mod_name(ctx, ns) when is_list(ns) do
    prefix = prefixed_name(ctx)
    ns |> join_name() |> attach_pkg(prefix)
  end

  def mod_name(ctx, ns) do
    prefix = prefixed_name(ctx)
    attach_pkg(ns, prefix)
  end

  def prefixed_name(%{package_prefix: nil, module_prefix: nil, package: pkg} = _ctx),
    do: pkg

  def prefixed_name(%{package_prefix: prefix, module_prefix: nil, package: pkg} = _ctx),
    do: attach_raw_pkg(pkg, prefix)

  def prefixed_name(%{module_prefix: module_prefix} = _ctx),
    do: module_prefix

  defp attach_pkg(name, ""), do: name
  defp attach_pkg(name, nil), do: name
  defp attach_pkg(name, pkg), do: normalize_type_name(pkg) <> "." <> name

  def attach_raw_pkg(name, ""), do: name
  def attach_raw_pkg(name, nil), do: name
  def attach_raw_pkg("", pkg), do: pkg
  def attach_raw_pkg(nil, pkg), do: pkg
  def attach_raw_pkg(name, pkg), do: pkg <> "." <> name

  def options_to_str(opts) do
    opts
    |> Enum.filter(fn {_, v} -> v end)
    |> Enum.map(fn {k, v} -> "#{k}: #{print(v)}" end)
    |> Enum.join(", ")
  end

  def type_from_type_name(ctx, type_name) do
    # The doc says there's a situation where type_name begins without a `.`, but I never got that.
    # Handle that later.
    metadata =
      ctx.dep_type_mapping[type_name] ||
        raise "There's something wrong to get #{type_name}'s type, please contact with the lib author."

    metadata[:type_name]
  end

  def normalize_type_name(name) do
    name
    |> String.split(".")
    |> Enum.map(&Macro.camelize(&1))
    |> Enum.join(".")
  end

  def print(v) when is_atom(v), do: inspect(v)
  def print(v), do: v
end
