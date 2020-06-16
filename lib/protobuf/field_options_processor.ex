defmodule Protobuf.FieldOptionsProcessor do
  @moduledoc """
  Defines hooks to process custom field options.
  """

  @typedoc """
  Keyword list of field options. Right now only [extype: mytype].
  """
  @type options :: Keyword.t(String.t)

  @typedoc """
  The existing type of the field. Often the module name of the struct.
  """
  @type type :: atom

  @typedoc """
  A value with type extype.
  """
  @type value :: struct | any
  @callback type_to_spec(type_enum :: atom, type :: String.t(), repeated :: boolean, options) :: String.t()
  @callback type_default(type, options) :: any
  @callback new(type, value, options) :: value
  @callback encode_type(type, value, options) :: binary
  @callback decode_type(val :: binary, type, options) :: value

  def type_to_spec(type_enum, type, repeated, []) do
    Protobuf.TypeUtil.enum_to_spec(type_enum, type, repeated)
  end
  def type_to_spec(_type_enum, type, repeated, [extype: extype]) do
    Extype.type_to_spec(type, repeated, extype)
  end

  def type_default(type, []), do: Protobuf.Builder.type_default(type)
  def type_default(type, [extype: extype]), do: Extype.type_default(type, extype)

  def new(type, value, []), do: type.new(value)
  def new(type, value, [extype: extype]), do: Extype.new(type, value, extype)

  def encode_type(type, v, []), do: Protobuf.Encoder.encode(type, v, [])
  def encode_type(type, v, [extype: extype]), do: Extype.encode_type(type, v, extype)

  def decode_type(val, type, []), do: Protobuf.Decoder.decode(val, type)
  def decode_type(val, type, [extype: extype]), do: Extype.decode_type(val, type, extype)
end
