defmodule Protobuf.Protoc.Generator.Message do
  @moduledoc false
  alias Protobuf.Protoc.Generator.Util
  alias Protobuf.TypeUtil
  alias Protobuf.Protoc.Generator.Enum, as: EnumGenerator

  defp with_message_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [4, index]}
  end

  defp with_message_enum_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [5, index]}
  end

  defp with_message_field_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [2, index]}
  end

  defp with_message_oneof_path(%{location_path: path} = ctx, index) do
    %{ctx | location_path: path ++ [8, index]}
  end

  def generate_list(ctx, descs) do
    descs
    |> Enum.with_index()
    |> Enum.map(fn {desc, index} -> generate(with_message_path(ctx, index), desc) end)
    |> Enum.unzip()
  end

  def generate(ctx, desc) do
    msg_struct = parse_desc(ctx, desc)
    ctx = %{ctx | namespace: msg_struct[:new_namespace]}
    {nested_enums, nested_msgs} = Enum.unzip(gen_nested_msgs(ctx, desc))

    {gen_nested_enums(ctx, desc) ++ nested_enums, nested_msgs ++ [gen_msg(msg_struct)]}
  end

  def parse_desc(%{namespace: ns} = ctx, desc) do
    new_ns = ns ++ [Util.trans_name(desc.name)]
    fields = get_fields(ctx, desc)
    oneofs = get_oneofs(ctx, desc.oneof_decl)
    extensions = get_extensions(desc)
    generate_desc = if ctx.gen_descriptors?, do: desc, else: nil
    typespec = typespec_str(fields, oneofs, extensions)

    %{
      new_namespace: new_ns,
      name: Util.mod_name(ctx, new_ns),
      options: msg_opts_str(ctx, desc.options),
      structs: structs_str(desc, extensions),
      typespec: typespec,
      fields: gen_fields(ctx.syntax, fields),
      oneofs: gen_oneofs(oneofs),
      desc: generate_desc,
      extensions: extensions,
      docs:
        Util.moduledoc_str(
          ctx,
          String.contains?(typespec, "@typedoc")
        )
    }
  end

  defp gen_msg(msg_struct) do
    Protobuf.Protoc.Template.message(
      msg_struct[:name],
      msg_struct[:options],
      msg_struct[:structs],
      msg_struct[:typespec],
      msg_struct[:oneofs],
      msg_struct[:fields],
      msg_struct[:desc],
      gen_extensions(msg_struct[:extensions]),
      msg_struct[:docs]
    )
  end

  defp gen_nested_msgs(ctx, desc) do
    desc.nested_type
    |> Enum.with_index()
    |> Enum.map(fn {msg_desc, index} -> generate(with_message_path(ctx, index), msg_desc) end)
  end

  defp gen_nested_enums(ctx, desc) do
    desc.enum_type
    |> Enum.with_index()
    |> Enum.map(fn {enum_desc, index} ->
      EnumGenerator.generate(with_message_enum_path(ctx, index), enum_desc)
    end)
  end

  defp gen_fields(syntax, fields) do
    Enum.map(fields, fn %{opts_str: opts_str} = f ->
      label_str =
        if syntax == :proto3 && f[:label] != "repeated", do: "", else: "#{f[:label]}: true, "

      "field :#{f[:name]}, #{f[:number]}, #{label_str}type: #{f[:type]}#{opts_str}"
    end)
  end

  defp gen_extensions([]) do
    nil
  end

  defp gen_extensions(exts) do
    inspect(exts, limit: :infinity)
  end

  def msg_opts_str(%{syntax: syntax}, opts) do
    msg_options = opts

    opts = %{
      syntax: syntax,
      map: msg_options && msg_options.map_entry,
      deprecated: msg_options && msg_options.deprecated
    }

    str = Util.options_to_str(opts)
    if String.length(str) > 0, do: ", " <> str, else: ""
  end

  def structs_str(struct, extensions) do
    fields = Enum.filter(struct.field, fn f -> !f.oneof_index end)

    fields =
      if Enum.empty?(extensions) do
        fields
      else
        fields ++ [%{name: :__pb_extensions__}]
      end

    Enum.map_join(struct.oneof_decl ++ fields, ", ", fn f -> ":#{f.name}" end)
  end

  def typespec_str([], [], []), do: "  @type t :: %__MODULE__{}"
  def typespec_str([], [], [_ | _]), do: "  @type t :: %__MODULE__{__pb_extensions__: map}"

  def typespec_str(fields, oneofs, extensions) do
    dedicated_types =
      Enum.map(fields, fn field ->
        {field[:name], fmt_type(field), Util.fmt_doc_str(field[:location])}
      end)

    dedicated_types =
      dedicated_types ++
        Enum.map(oneofs, fn oneof ->
          type_str =
            fields
            |> Enum.filter(fn f ->
              f[:oneof] == oneof[:index]
            end)
            |> Enum.map_join(" | ", fn f ->
              "{:#{f[:name]}, #{Util.safe_type_name(f[:name])}()}"
            end)

          {oneof[:name], type_str <> " | nil", Util.fmt_doc_str(oneof[:location])}
        end)

    dedicated_types =
      if Enum.empty?(extensions) do
        dedicated_types
      else
        dedicated_types ++ [{:__pb_extensions__, "map", ""}]
      end

    dedicated_types_str =
      dedicated_types
      |> Enum.flat_map(fn {name, spec, docs} ->
        type_spec_str = "  @type #{Util.safe_type_name(name)} :: #{spec}"

        if String.length(String.trim(docs)) > 0 do
          [
            "",
            "  @typedoc \"\"\"",
            docs,
            "\"\"\"",
            type_spec_str,
            ""
          ]
        else
          [type_spec_str]
        end
      end)
      |> Enum.join("\n")

    aggregated_field_types =
      fields
      |> Enum.filter(fn f -> !f[:oneof] end)
      |> Enum.map(& &1[:name])

    aggregated_oneof_types = oneofs |> Enum.map(& &1[:name])

    aggregated_type_fields_str =
      (aggregated_field_types ++ aggregated_oneof_types)
      |> Enum.map_join(",\n", fn name ->
        "    #{name}: #{Util.safe_type_name(name)}()"
      end)

    aggregated_type_str =
      [
        "  @type t :: %__MODULE__{",
        aggregated_type_fields_str,
        "  }"
      ]
      |> Enum.join("\n")

    dedicated_types_str <> "\n" <> aggregated_type_str
  end

  defp gen_oneofs(oneofs) do
    oneofs
    |> Enum.map(fn oneof ->
      "oneof :#{oneof.name}, #{oneof.index}"
    end)
  end

  defp fmt_type(%{opts: %{map: true}, map: {{k_type, k_name}, {v_type, v_name}}}) do
    k_type = type_to_spec(k_type, k_name)
    v_type = type_to_spec(v_type, v_name)
    "%{#{k_type} => #{v_type}}"
  end

  defp fmt_type(%{label: "repeated", type_enum: type_enum, type: type}) do
    "[#{type_to_spec(type_enum, type, true)}]"
  end

  defp fmt_type(%{type_enum: type_enum, type: type}) do
    "#{type_to_spec(type_enum, type)}"
  end

  defp type_to_spec(enum, type, repeated \\ false)

  defp type_to_spec(:TYPE_MESSAGE, type, repeated),
    do: TypeUtil.enum_to_spec(:TYPE_MESSAGE, type, repeated)

  defp type_to_spec(:TYPE_ENUM, type, repeated),
    do: TypeUtil.enum_to_spec(:TYPE_ENUM, type, repeated)

  defp type_to_spec(enum, _, _), do: TypeUtil.enum_to_spec(enum)

  def get_oneofs(ctx, oneofs) do
    oneofs
    |> Enum.with_index()
    |> Enum.map(fn {oneof, index} ->
      %{
        name: oneof.name,
        index: index,
        location: Util.find_location(with_message_oneof_path(ctx, index))
      }
    end)
  end

  def get_fields(ctx, desc) do
    oneofs = Enum.map(desc.oneof_decl, & &1.name)
    nested_maps = nested_maps(ctx, desc)

    desc.field
    |> Enum.with_index()
    |> Enum.map(fn {f, index} ->
      get_field(with_message_field_path(ctx, index), f, nested_maps, oneofs)
    end)
  end

  def get_field(
        ctx,
        f,
        nested_maps,
        oneofs
      ) do
    opts = field_options(f, ctx.syntax)
    map = nested_maps[f.type_name]
    opts = if map, do: Map.put(opts, :map, true), else: opts

    opts =
      if length(oneofs) > 0 && f.oneof_index, do: Map.put(opts, :oneof, f.oneof_index), else: opts

    opts_str = Util.options_to_str(opts)
    opts_str = if opts_str == "", do: "", else: ", " <> opts_str

    type = field_type_name(ctx, f)

    %{
      name: f.name,
      number: f.number,
      label: label_name(f.label),
      type: type,
      type_enum: f.type,
      opts: opts,
      opts_str: opts_str,
      map: map,
      oneof: f.oneof_index,
      location: Util.find_location(ctx)
    }
  end

  defp get_extensions(desc) do
    Enum.map(desc.extension_range, fn range ->
      {range.start, range.end}
    end)
  end

  defp field_type_name(ctx, f) do
    type = TypeUtil.from_enum(f.type)

    if f.type_name && (type == :enum || type == :message) do
      Util.type_from_type_name(ctx, f.type_name)
    else
      ":#{type}"
    end
  end

  # Map of protobuf are actually nested(one level) messages
  defp nested_maps(ctx, desc) do
    full_name = Util.join_name([ctx.package | ctx.namespace] ++ [desc.name])
    prefix = "." <> full_name

    Enum.reduce(desc.nested_type, %{}, fn desc, acc ->
      if desc.options && desc.options.map_entry do
        [k, v] = Enum.sort(desc.field, &(&1.number < &2.number))

        pair = {{k.type, field_type_name(ctx, k)}, {v.type, field_type_name(ctx, v)}}

        Map.put(acc, Util.join_name([prefix, desc.name]), pair)
      else
        acc
      end
    end)
  end

  defp field_options(f, syntax) do
    enum? = f.type == :TYPE_ENUM
    default = default_value(f.type, f.default_value)

    %{enum: enum?, default: default}
    |> put_json_name(syntax, f)
    |> merge_field_options(f)
  end

  defp label_name(:LABEL_OPTIONAL), do: "optional"
  defp label_name(:LABEL_REQUIRED), do: "required"
  defp label_name(:LABEL_REPEATED), do: "repeated"

  defp default_value(_, ""), do: nil
  defp default_value(_, nil), do: nil

  defp default_value(t, val) do
    v = do_default_value(t, val)
    if v == nil, do: v, else: inspect(v)
  end

  defp do_default_value(:TYPE_DOUBLE, v), do: float_default(v)
  defp do_default_value(:TYPE_FLOAT, v), do: float_default(v)
  defp do_default_value(:TYPE_INT64, v), do: int_default(v)
  defp do_default_value(:TYPE_UINT64, v), do: int_default(v)
  defp do_default_value(:TYPE_INT32, v), do: int_default(v)
  defp do_default_value(:TYPE_FIXED64, v), do: int_default(v)
  defp do_default_value(:TYPE_FIXED32, v), do: int_default(v)
  defp do_default_value(:TYPE_BOOL, v), do: String.to_atom(v)
  defp do_default_value(:TYPE_STRING, v), do: v
  defp do_default_value(:TYPE_BYTES, v), do: v
  defp do_default_value(:TYPE_UINT32, v), do: int_default(v)
  defp do_default_value(:TYPE_ENUM, v), do: String.to_atom(v)
  defp do_default_value(:TYPE_SFIXED32, v), do: int_default(v)
  defp do_default_value(:TYPE_SFIXED64, v), do: int_default(v)
  defp do_default_value(:TYPE_SINT32, v), do: int_default(v)
  defp do_default_value(:TYPE_SINT64, v), do: int_default(v)
  defp do_default_value(_, _), do: nil

  defp float_default(value) do
    case Float.parse(value) do
      {v, _} -> v
      :error -> value
    end
  end

  defp int_default(value) do
    case Integer.parse(value) do
      {v, _} -> v
      :error -> value
    end
  end

  defp merge_field_options(opts, %{options: nil}), do: opts

  defp merge_field_options(opts, f) do
    opts
    |> Map.put(:packed, f.options.packed)
    |> Map.put(:deprecated, f.options.deprecated)
  end

  # Omit `json_name` from the options list when it matches the original field
  # name to keep the list small. Only Proto3 has JSON support for now.
  defp put_json_name(opts, :proto3, %{name: name, json_name: name}), do: opts

  defp put_json_name(opts, :proto3, %{json_name: json_name}) do
    Map.put(opts, :json_name, inspect(json_name))
  end

  defp put_json_name(opts, _syntax, _props), do: opts
end
