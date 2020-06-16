defmodule Protobuf.Protoc.Generator.Util do
  @moduledoc false
  def trans_name(name) do
    Macro.camelize(name)
  end

  def join_name(list) do
    Enum.join(list, ".")
  end

  def mod_name(%{module_prefix: prefix}, ns) when is_list(ns) do
    ns |> join_name() |> attach_pkg(prefix)
  end

  def mod_name(%{module_prefix: prefix}, ns) do
    attach_pkg(ns, prefix)
  end

  defp attach_pkg(name, ""), do: name
  defp attach_pkg(name, nil), do: name
  defp attach_pkg(name, pkg), do: normalize_type_name(pkg) <> "." <> name

  def attach_raw_pkg(name, ""), do: name
  def attach_raw_pkg(name, nil), do: name
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
  def print(v) when is_list(v), do: inspect(v)
  def print(v), do: v
end
