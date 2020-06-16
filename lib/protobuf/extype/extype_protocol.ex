defprotocol Extype.Protocol do
  @moduledoc """
  Protocol for defining an elixir type for a protobuf type.
  """
  @typedoc """
  An elixir type.
  """
  @type extype :: String.t()

  @typedoc """
  The existing type of the field. Often the module name of the struct.
  """
  @type type :: atom

  @typedoc """
  A value with type extype.
  """
  @type value :: struct | any

  @spec validate_and_to_atom_extype!(type, option :: String.t) :: atom
  def validate_and_to_atom_extype!(type, option)

  @spec type_default(type, extype) :: any
  def type_default(type, extype)

  @spec new(type, value, extype) :: value
  def new(type, value, extype)

  @spec encode_type(type, value, extype) :: binary
  def encode_type(type, v, extype)

  @spec decode_type(type, val :: binary, extype) :: value
  def decode_type(val, type, extype)
end

defmodule Extype do
  @moduledoc "Extype"

  @type extype :: Extype.Protocol.extype
  @type type :: Extype.Protocol.type
  @type value :: Extype.Protocol.value

  # A serious trick
  def get_mod(type) when is_atom(type) do
    try do
      Extype.Protocol.impl_for!(%{__struct__: type})
    rescue
      _exception ->
        reraise "Sorry #{type} does not support the field option extype", __STACKTRACE__
    end
  end

  @spec type_to_spec(type :: String.t(), repeated :: boolean, extype) :: String.t()
  def type_to_spec(_type, repeated, extype) do
    extype = pad_parens(extype)
    if repeated do
      "[#{extype}]"
    else
      extype <> " | nil"
    end
  end

  @spec type_default(type, extype) :: any
  def type_default(type, extype) do
    mod = get_mod(type)
    extype = pad_parens(extype)
    atom_extype = mod.validate_and_to_atom_extype!(type, extype)
    mod.type_default(type, atom_extype)
  end

  @spec new(type, value, extype) :: value
  def new(type, value, extype) do
    mod = get_mod(type)
    extype = pad_parens(extype)
    atom_extype = mod.validate_and_to_atom_extype!(type, extype)
    mod.new(type, value, atom_extype)
  end

  @spec encode_type(type, value, extype) :: binary
  def encode_type(type, v, extype) do
    mod = get_mod(type)
    extype = pad_parens(extype)
    atom_extype  = mod.validate_and_to_atom_extype!(type, extype)
    mod.encode_type(type, v, atom_extype)
  end

  @spec decode_type(val :: binary, type, extype) :: value
  def decode_type(val, type, extype) do
    mod = get_mod(type)
    extype = pad_parens(extype)
    atom_extype = mod.validate_and_to_atom_extype!(type, extype)
    mod.decode_type(type, val, atom_extype)
  end

  defp pad_parens(extype) do
    if String.ends_with?(extype, ".t") do
      extype <> "()"
    else
      extype
    end
  end
end
