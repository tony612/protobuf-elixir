defmodule Protobuf.Protoc.Generator.Enum do
  @moduledoc false
  alias Protobuf.Protoc.Generator.Util

  defp with_enum_message_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [5, index]}
  end

  def generate_list(ctx, descs) do
    descs
    |> Enum.with_index()
    |> Enum.map(fn {desc, index} -> generate(with_enum_message_path(ctx, index), desc) end)
  end

  def generate(%{namespace: ns} = ctx, desc) do
    name = Util.trans_name(desc.name)
    fields = Enum.map(desc.value, fn f -> generate_field(f) end)
    msg_name = Util.mod_name(ctx, ns ++ [name])
    generate_desc = if ctx.gen_descriptors?, do: desc, else: nil
    type = generate_type(ctx, desc.value)

    docs =
      Util.moduledoc_str(
        ctx,
        String.contains?(type, "@typedoc")
      )

    Protobuf.Protoc.Template.enum(
      msg_name,
      msg_opts(ctx, desc),
      fields,
      type,
      generate_desc,
      docs
    )
  end

  defp with_enum_value_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [2, index]}
  end

  def generate_type(ctx, fields) do
    value_types =
      fields
      |> Enum.with_index()
      |> Enum.map(fn {f, index} ->
        {f.name, Util.find_location(ctx |> with_enum_value_path(index)) |> Util.fmt_doc_str()}
      end)

    dedicated_type_str =
      value_types
      |> Enum.flat_map(fn {name, docs} ->
        type_str = "@type #{Util.safe_type_name(name)} :: :#{name}"

        if String.length(String.trim(docs)) > 0 do
          ["", "@typedoc \"\"\"", docs, "\"\"\"", type_str, ""]
        else
          [type_str]
        end
      end)
      |> Enum.join("\n")

    field_values =
      fields
      |> Enum.map(fn f -> "#{Util.safe_type_name(f.name)}()" end)
      |> Enum.join(" | ")

    aggregate_type_str = "@type t :: integer | " <> field_values

    dedicated_type_str <> "\n" <> aggregate_type_str
  end

  def generate_field(f) do
    ":#{f.name}, #{f.number}"
  end

  defp msg_opts(%{syntax: syntax}, _desc) do
    opts = %{syntax: syntax, enum: true}
    str = Util.options_to_str(opts)
    ", " <> str
  end
end
