defmodule Protobuf.Encoder do
  @moduledoc false
  import Protobuf.WireTypes
  import Bitwise, only: [bsr: 2, band: 2, bsl: 2, bor: 2]

  alias Protobuf.{MessageProps, FieldProps}

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

    if skip_field?(syntax, val, prop) || skip_enum?(prop, val) do
      encode_fields(tail, syntax, struct, oneofs, acc)
    else
      acc = [encode_field(class_field(prop), val, prop) | acc]
      encode_fields(tail, syntax, struct, oneofs, acc)
    end
  rescue
    error ->
      stacktrace = System.stacktrace()

      msg =
        "Got error when encoding #{inspect(struct.__struct__)}##{prop.name_atom}: #{
          Exception.format(:error, error)
        }"

      throw({Protobuf.EncodeError, [message: msg], stacktrace})
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
   defp encode_field(
         :custom,
         val,
         %{encoded_fnum: fnum, repeated?: is_repeated, map?: is_map, type: type, options: options} =
           prop
       ) do
    repeated = is_repeated || is_map

    repeated_or_not(val, repeated, fn v ->
      v = if is_map, do: struct(prop.type, %{key: elem(v, 0), value: elem(v, 1)}), else: v
      encoded = Protobuf.FieldOptionsProcessor.encode_type(type, v, options)
      byte_size = byte_size(encoded)
      [fnum, encode_varint(byte_size), encoded]
    end)
  end

  defp encode_field(:normal, val, %{encoded_fnum: fnum, type: type, repeated?: is_repeated}) do
    repeated_or_not(val, is_repeated, fn v ->
      [fnum, encode_type(type, v)]
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
      encoded = encode(type, v, [])
      byte_size = byte_size(encoded)
      [fnum, encode_varint(byte_size), encoded]
    end)
  end

  defp encode_field(:packed, val, %{type: type, encoded_fnum: fnum}) do
    encoded = Enum.map(val, fn v -> encode_type(type, v) end)
    byte_size = IO.iodata_length(encoded)
    [fnum, encode_varint(byte_size), encoded]
  end

  @spec class_field(map) :: atom
  defp class_field(%{options: options}) when not is_nil(options) do
    :custom
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
  @spec encode_fnum(integer, integer) :: iodata
  def encode_fnum(fnum, wire_type) do
    fnum
    |> bsl(3)
    |> bor(wire_type)
    |> encode_varint
  end

  @doc false
  @spec encode_type(atom, any) :: iodata
  def encode_type(:int32, n) when n >= -0x80000000 and n <= 0x7FFFFFFF, do: encode_varint(n)

  def encode_type(:int64, n) when n >= -0x8000000000000000 and n <= 0x7FFFFFFFFFFFFFFF,
    do: encode_varint(n)

  def encode_type(:string, n), do: encode_type(:bytes, n)
  def encode_type(:uint32, n) when n >= 0 and n <= 0xFFFFFFFF, do: encode_varint(n)
  def encode_type(:uint64, n) when n >= 0 and n <= 0xFFFFFFFFFFFFFFFF, do: encode_varint(n)
  def encode_type(:bool, true), do: encode_varint(1)
  def encode_type(:bool, false), do: encode_varint(0)
  def encode_type({:enum, type}, n) when is_atom(n), do: n |> type.value() |> encode_varint()
  def encode_type({:enum, _}, n), do: encode_varint(n)
  def encode_type(:float, :infinity), do: <<0, 0, 128, 127>>
  def encode_type(:float, :negative_infinity), do: <<0, 0, 128, 255>>
  def encode_type(:float, :nan), do: <<0, 0, 192, 127>>
  def encode_type(:float, n), do: <<n::32-float-little>>
  def encode_type(:double, :infinity), do: <<0, 0, 0, 0, 0, 0, 240, 127>>
  def encode_type(:double, :negative_infinity), do: <<0, 0, 0, 0, 0, 0, 240, 255>>
  def encode_type(:double, :nan), do: <<1, 0, 0, 0, 0, 0, 248, 127>>
  def encode_type(:double, n), do: <<n::64-float-little>>

  def encode_type(:bytes, n) do
    bin = IO.iodata_to_binary(n)
    len = bin |> byte_size |> encode_varint
    <<len::binary, bin::binary>>
  end

  def encode_type(:sint32, n) when n >= -0x80000000 and n <= 0x7FFFFFFF,
    do: n |> encode_zigzag |> encode_varint

  def encode_type(:sint64, n) when n >= -0x8000000000000000 and n <= 0x7FFFFFFFFFFFFFFF,
    do: n |> encode_zigzag |> encode_varint

  def encode_type(:fixed64, n) when n >= 0 and n <= 0xFFFFFFFFFFFFFFFF, do: <<n::64-little>>

  def encode_type(:sfixed64, n) when n >= -0x8000000000000000 and n <= 0x7FFFFFFFFFFFFFFF,
    do: <<n::64-signed-little>>

  def encode_type(:fixed32, n) when n >= 0 and n <= 0xFFFFFFFF, do: <<n::32-little>>

  def encode_type(:sfixed32, n) when n >= -0x80000000 and n <= 0x7FFFFFFF,
    do: <<n::32-signed-little>>

  def encode_type(type, n) do
    raise Protobuf.TypeEncodeError, message: "#{inspect(n)} is invalid for type #{type}"
  end

  @spec encode_zigzag(integer) :: integer
  defp encode_zigzag(val) when val >= 0, do: val * 2
  defp encode_zigzag(val) when val < 0, do: val * -2 - 1

  @doc false
  @spec encode_varint(integer) :: iodata
  def encode_varint(n) when n < 0 do
    <<n::64-unsigned-native>> = <<n::64-signed-native>>
    encode_varint(n)
  end

  def encode_varint(n) when n <= 127 do
    <<n>>
  end

  def encode_varint(n) do
    [<<1::1, band(n, 127)::7>> | encode_varint(bsr(n, 7))] |> IO.iodata_to_binary()
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

  defp skip_enum?(prop, value)
  defp skip_enum?(%{enum?: false}, _), do: false
  defp skip_enum?(%{enum?: true, oneof: oneof}, _) when not is_nil(oneof), do: false
  defp skip_enum?(%{required?: true}, _), do: false
  defp skip_enum?(%{type: type}, value), do: is_enum_default?(type, value)

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
          if skip_field?(:proto2, val, prop) || skip_enum?(prop, val) do
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
