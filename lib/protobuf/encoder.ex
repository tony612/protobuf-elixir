defmodule Protobuf.Encoder do
  @moduledoc false
  import Protobuf.Wire.Types
  import Bitwise, only: [bsl: 2, bor: 2]

  alias Protobuf.{FieldProps, MessageProps, Wire, Wire.Varint}

  @spec encode(atom, map | struct, keyword) :: iodata
  def encode(mod, msg, opts) do
    case msg do
      %{__struct__: ^mod} ->
        encode(msg, opts)

      _ ->
        encode(mod.new(msg), opts)
    end
  end

  @spec encode(struct, keyword) :: iodata
  def encode(%mod{} = struct, opts \\ []) do
    res = encode!(struct, mod.__message_props__())

    case Keyword.fetch(opts, :iolist) do
      {:ok, true} -> res
      _ -> IO.iodata_to_binary(res)
    end
  end

  @spec encode!(struct, MessageProps.t()) :: iodata
  def encode!(struct, %{field_props: field_props} = props) do
    syntax = props.syntax
    oneofs = oneof_actual_vals(props, struct)

    encoded = encode_fields(Map.values(field_props), syntax, struct, oneofs, [])

    encoded =
      if syntax == :proto2 do
        encode_extensions(struct, encoded)
      else
        encoded
      end

    encoded
    |> Enum.reverse()
  catch
    {e, msg, st} ->
      reraise e, msg, st
  end

  defp encode_fields([], _, _, _, acc) do
    acc
  end

  defp encode_fields([prop | tail], syntax, struct, oneofs, acc) do
    %{name_atom: name, oneof: oneof} = prop

    val =
      if oneof do
        oneofs[name]
      else
        case struct do
          %{^name => v} ->
            v

          _ ->
            nil
        end
      end

    if skip_field?(syntax, val, prop) || skip_enum?(syntax, val, prop) do
      encode_fields(tail, syntax, struct, oneofs, acc)
    else
      acc = [encode_field(class_field(prop), val, prop) | acc]
      encode_fields(tail, syntax, struct, oneofs, acc)
    end
  rescue
    error ->
      msg =
        "Got error when encoding #{inspect(struct.__struct__)}##{prop.name_atom}: #{
          Exception.format(:error, error)
        }"

      throw({Protobuf.EncodeError, [message: msg], __STACKTRACE__})
  end

  @doc false
  def skip_field?(syntax, val, prop)
  def skip_field?(_, [], _), do: true
  def skip_field?(_, v, _) when map_size(v) == 0, do: true
  def skip_field?(:proto2, nil, %{optional?: true}), do: true
  def skip_field?(:proto3, nil, _), do: true
  def skip_field?(:proto3, 0, %{oneof: nil}), do: true
  def skip_field?(:proto3, 0.0, %{oneof: nil}), do: true
  def skip_field?(:proto3, "", %{oneof: nil}), do: true
  def skip_field?(:proto3, false, %{oneof: nil}), do: true
  def skip_field?(_, _, _), do: false

  @spec encode_field(atom, any, FieldProps.t()) :: iodata
  defp encode_field(:normal, val, %{encoded_fnum: fnum, type: type, repeated?: is_repeated}) do
    repeated_or_not(val, is_repeated, fn v ->
      [fnum | Wire.from_proto(type, v)]
    end)
  end

  defp encode_field(
         :embedded,
         val,
         %{encoded_fnum: fnum, repeated?: is_repeated, map?: is_map, type: type} = prop
       ) do
    repeated = is_repeated || is_map

    repeated_or_not(val, repeated, fn v ->
      v = if is_map, do: struct(prop.type, %{key: elem(v, 0), value: elem(v, 1)}), else: v
      # so that oneof {:atom, v} can be encoded
      encoded = encode(type, v, iolist: true)
      byte_size = IO.iodata_length(encoded)
      [fnum | Varint.encode(byte_size)] ++ encoded
    end)
  end

  defp encode_field(:packed, val, %{type: type, encoded_fnum: fnum}) do
    encoded = Enum.map(val, fn v -> Wire.from_proto(type, v) end)
    byte_size = IO.iodata_length(encoded)
    [fnum | Varint.encode(byte_size)] ++ encoded
  end

  @spec class_field(map) :: atom
  defp class_field(%{wire_type: wire_delimited(), embedded?: true}) do
    :embedded
  end

  defp class_field(%{repeated?: true, packed?: true}) do
    :packed
  end

  defp class_field(_) do
    :normal
  end

  @doc false
  @spec encode_fnum(integer, integer) :: binary
  def encode_fnum(fnum, wire_type) do
    fnum
    |> bsl(3)
    |> bor(wire_type)
    |> Varint.encode()
    |> IO.iodata_to_binary()
  end

  @doc false
  @spec wire_type(atom) :: integer
  def wire_type(:int32), do: wire_varint()
  def wire_type(:int64), do: wire_varint()
  def wire_type(:uint32), do: wire_varint()
  def wire_type(:uint64), do: wire_varint()
  def wire_type(:sint32), do: wire_varint()
  def wire_type(:sint64), do: wire_varint()
  def wire_type(:bool), do: wire_varint()
  def wire_type({:enum, _}), do: wire_varint()
  def wire_type(:enum), do: wire_varint()
  def wire_type(:fixed64), do: wire_64bits()
  def wire_type(:sfixed64), do: wire_64bits()
  def wire_type(:double), do: wire_64bits()
  def wire_type(:string), do: wire_delimited()
  def wire_type(:bytes), do: wire_delimited()
  def wire_type(:fixed32), do: wire_32bits()
  def wire_type(:sfixed32), do: wire_32bits()
  def wire_type(:float), do: wire_32bits()
  def wire_type(mod) when is_atom(mod), do: wire_delimited()

  defp repeated_or_not(val, repeated, func) do
    if repeated do
      Enum.map(val, func)
    else
      func.(val)
    end
  end

  defp skip_enum?(syntax, prop, value)
  defp skip_enum?(:proto2, _, _), do: false
  defp skip_enum?(_, _, %{enum?: false}), do: false
  defp skip_enum?(_, _, %{enum?: true, oneof: oneof}) when not is_nil(oneof), do: false
  defp skip_enum?(_, _, %{required?: true}), do: false
  defp skip_enum?(_, value, %{type: type}), do: is_enum_default?(type, value)

  defp is_enum_default?({_, type}, v) when is_atom(v), do: type.value(v) == 0
  defp is_enum_default?({_, _}, v) when is_integer(v), do: v == 0
  defp is_enum_default?({_, _}, _), do: false

  defp oneof_actual_vals(
         %{field_tags: field_tags, field_props: field_props, oneof: oneof},
         struct
       ) do
    Enum.reduce(oneof, %{}, fn {field, index}, acc ->
      case Map.get(struct, field, nil) do
        {f, val} ->
          %{oneof: oneof} = field_props[field_tags[f]]

          if oneof != index do
            raise Protobuf.EncodeError,
              message: ":#{f} doesn't belongs to #{inspect(struct.__struct__)}##{field}"
          else
            Map.put(acc, f, val)
          end

        nil ->
          acc

        _ ->
          raise Protobuf.EncodeError,
            message: "#{inspect(struct.__struct__)}##{field} should be {key, val} or nil"
      end
    end)
  end

  defp encode_extensions(%mod{__pb_extensions__: pb_exts}, encoded) when is_map(pb_exts) do
    Enum.reduce(pb_exts, encoded, fn {{ext_mod, key}, val}, acc ->
      case Protobuf.Extension.get_extension_props(mod, ext_mod, key) do
        %{field_props: prop} ->
          if skip_field?(:proto2, val, prop) do
            encoded
          else
            [encode_field(class_field(prop), val, prop) | acc]
          end

        _ ->
          acc
      end
    end)
  end

  defp encode_extensions(_, encoded) do
    encoded
  end
end
