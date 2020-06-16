defimpl Extype.Protocol, for: Google.Protobuf.Timestamp do
  @moduledoc """
  Implement DateTime and NaiveDateTime casting for Google Timestamp.
  """

  def validate_and_to_atom_extype!(Google.Protobuf.Timestamp, "NaiveDateTime.t()"), do: :naivedatetime
  def validate_and_to_atom_extype!(Google.Protobuf.Timestamp, "DateTime.t()"), do: :datetime
  def validate_and_to_atom_extype!(type, extype) do
    raise "Invalid extype pairing, #{extype} not compatible with #{type}. " <>
      "Supported types are DateTime.t() or NaiveDateTime.t()"
  end

  def type_default(_type, _extype), do: nil

  def new(_type, value, _extype), do: value

  def encode_type(_type, v, extype) do
    v = if extype == :naivedatetime, do: DateTime.from_naive!(v, "Etc/UTC"), else: v

    unix = DateTime.to_unix(v, :nanosecond)

    seconds = System.convert_time_unit(unix, :nanosecond, :second)
    nanos = unix - System.convert_time_unit(seconds, :second, :nanosecond)

    value = Google.Protobuf.Timestamp.new(seconds: seconds, nanos: nanos)

    Protobuf.encode(value)
  end

  def decode_type(type, val, extype) do
    protobuf_timestamp = Protobuf.decode(val, type)

    value =
      protobuf_timestamp.seconds
      |> System.convert_time_unit(:second, :nanosecond)
      |> Kernel.+(protobuf_timestamp.nanos)
      |> DateTime.from_unix!(:nanosecond)

    if extype == :naivedatetime, do: DateTime.to_naive(value), else: value
  end
end
