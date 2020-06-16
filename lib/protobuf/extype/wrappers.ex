defimpl Extype.Protocol, for: [
    Google.Protobuf.DoubleValue,
    Google.Protobuf.FloatValue,
    Google.Protobuf.Int64Value,
    Google.Protobuf.UInt64Value,
    Google.Protobuf.Int32Value,
    Google.Protobuf.UInt32Value,
    Google.Protobuf.BoolValue,
    Google.Protobuf.StringValue,
    Google.Protobuf.BytesValue
  ] do

  @moduledoc """
    Implement value unwrapping for Google Wrappers.
  """

  require Protobuf.Decoder
  require Logger
  import Protobuf.Decoder, only: [decode_zigzag: 1]

  def validate_and_to_atom_extype!(Google.Protobuf.DoubleValue, "float"), do: :double
  def validate_and_to_atom_extype!(Google.Protobuf.FloatValue, "float"), do: :float
  def validate_and_to_atom_extype!(Google.Protobuf.Int64Value, "integer"), do: :int64
  def validate_and_to_atom_extype!(Google.Protobuf.UInt64Value, "non_neg_integer"), do: :uint64
  def validate_and_to_atom_extype!(Google.Protobuf.Int32Value, "integer"), do: :int32
  def validate_and_to_atom_extype!(Google.Protobuf.UInt32Value, "non_neg_integer"), do: :uint32
  def validate_and_to_atom_extype!(Google.Protobuf.BoolValue, "boolean"), do: :bool
  def validate_and_to_atom_extype!(Google.Protobuf.StringValue, "String.t()"), do: :string
  def validate_and_to_atom_extype!(Google.Protobuf.BytesValue, "String.t()"), do: :bytes
  def validate_and_to_atom_extype!(type, extype) do
    raise "Invalid extype pairing, #{extype} not compatible with #{type}"
  end

  def type_default(_type, _extype), do: nil

  def new(_type, value, _extype) do
    # No type check, just shape check.
    if is_map(value) do
      raise "When extype option is present, new expects unwrapped value, not struct."
    else
      value
    end
  end

  def encode_type(type, v, extype) do
    fnum = type.__message_props__.field_props[1].encoded_fnum
    encoded = Protobuf.Encoder.encode_type(extype, v)
    IO.iodata_to_binary([[fnum, encoded]])
  end

  def decode_type(_type, val, extype) do
    [_tag, _wire, val | _rest] = Protobuf.Decoder.decode_raw(val)
    Protobuf.Decoder.decode_type_m(extype, :value, val)
  end
end
