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
  def print(v), do: v

  @spec fmt_doc_str(%Google.Protobuf.SourceCodeInfo.Location{} | nil) :: String.t()
  def fmt_doc_str(%Google.Protobuf.SourceCodeInfo.Location{
        leading_comments: leading_comments,
        leading_detached_comments: leading_detached_comments,
        trailing_comments: trailing_comments
      }) do
    all_comments = leading_detached_comments ++ [leading_comments, trailing_comments]

    all_comments
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(&String.split(&1, "\n"))
    # only remove the first whitespace
    # this is typical for comments like
    #
    #   // single whitespace after `// `
    #
    # or
    #
    #   /* single whitespace after `/* `
    #    * and after `* `
    #    */
    |> Enum.map(&String.replace_prefix(&1, " ", ""))
    |> Enum.join("\n")
    |> String.trim_leading()
    |> String.trim_trailing()
  end

  def fmt_doc_str(nil) do
    ""
  end

  def find_location(%{
        source_code_info: %Google.Protobuf.SourceCodeInfo{} = source_code_info,
        location_path: location_path
      }) do
    source_code_info.location |> Enum.find(&(&1.path == location_path))
  end

  def find_location(_) do
    nil
  end

  @spec safe_type_name(binary()) :: binary()
  def safe_type_name(name) do
    name = name |> to_string() |> String.downcase()

    try do
      original_compiler_options = Code.compiler_options()

      # `Code.compile_string/2` will also load the compiled module into memory causing: `warning: redefining module SafeTypeNameWrapper (current version defined in memory)`
      # to disable these temporarily we modify the compiler options
      Code.compiler_options(ignore_module_conflict: true)

      # this will fail for names like
      # - `or` that are elixir operators and therefore are limited in how they can be used
      # - `number` and other predefined types which can not be redefined (see: https://hexdocs.pm/elixir/typespecs.html)
      Code.compile_string("defmodule SafeTypeNameWrapper do @type #{name} :: any() end")

      # reset to the original/unmodified compiler options
      Code.compiler_options(original_compiler_options)

      name
    rescue
      _ ->
        name <> "_"
    end
  end

  def moduledoc_str(ctx, other_doc_present \\ false) do
    case find_location(ctx) do
      %Google.Protobuf.SourceCodeInfo.Location{} = location ->
        "@moduledoc \"\"\"\n" <>
          fmt_doc_str(location) <>
          "\n\"\"\""

      _ ->
        if other_doc_present do
          ""
        else
          "@moduledoc false"
        end
    end
  end

  def to_grpc_handler_func_name(name) do
    name |> to_string |> Macro.underscore() |> String.to_atom()
  end
end
