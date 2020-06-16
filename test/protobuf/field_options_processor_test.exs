defmodule Protobuf.FieldOptionsProcessorTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Protobuf.FieldOptionsProcessor

  test "type_to_spec String.t and StringValue" do
    extype = "String.t"
    assert FieldOptionsProcessor.type_to_spec(:TYPE_MESSAGE, "Google.Protobuf.StringValue", false, [extype: extype]) ==
      extype <> "() | nil"
  end

  test "type_to_spec String.t() and StringValue" do
    extype = "String.t()"
    assert FieldOptionsProcessor.type_to_spec(:TYPE_MESSAGE, "Google.Protobuf.StringValue", false, [extype: extype]) ==
      extype <> " | nil"
  end

  test "type_to_spec repeated" do
    assert FieldOptionsProcessor.type_to_spec(:TYPE_MESSAGE, "Google.Protobuf.StringValue", true, [extype: "String.t()"]) ==
      "[String.t()]"

    # Note: Doesn't check against bad values
    assert FieldOptionsProcessor.type_to_spec(:TYPE_MESSAGE, "Google.Protobuf.UnrealValue", false, [extype: "vfdkhnlim"]) ==
      "vfdkhnlim | nil"
  end

  test "type_default" do

    assert is_nil(FieldOptionsProcessor.type_default(Google.Protobuf.BoolValue, extype: "boolean"))

    assert is_nil(FieldOptionsProcessor.type_default(Google.Protobuf.Timestamp, extype: "DateTime.t()"))
    assert is_nil(FieldOptionsProcessor.type_default(Google.Protobuf.Timestamp, extype: "DateTime.t"))
    assert is_nil(FieldOptionsProcessor.type_default(Google.Protobuf.Timestamp, extype: "NaiveDateTime.t()"))

    # Typo in extype
    assert_raise RuntimeError, "Invalid extype pairing, Datetime.t() not compatible with " <>
      "Elixir.Google.Protobuf.Timestamp. Supported types are DateTime.t() or NaiveDateTime.t()",
      fn -> FieldOptionsProcessor.type_default(Google.Protobuf.Timestamp, extype: "Datetime.t") end

    # Unsupported struct and bad type
    assert_raise RuntimeError, "Sorry Elixir.Google.Protobuf.UnrealValue does not support the field option extype",
      fn -> FieldOptionsProcessor.type_default(Google.Protobuf.UnrealValue, [extype: "vfdkhnlim"]) end
  end

  test "encoding and decoding timestamp" do
    dt = DateTime.utc_now()
    ndt = DateTime.to_naive(dt)

    output = FieldOptionsProcessor.encode_type(Google.Protobuf.Timestamp, dt, extype: "DateTime.t")
    output1 = FieldOptionsProcessor.encode_type(Google.Protobuf.Timestamp, ndt, extype: "NaiveDateTime.t")

    assert output == output1

    assert FieldOptionsProcessor.decode_type(output, Google.Protobuf.Timestamp, extype: "DateTime.t") == dt

    assert FieldOptionsProcessor.decode_type(output, Google.Protobuf.Timestamp, extype: "NaiveDateTime.t") == ndt

    # DateTime.from_naive accepts DateTime.t as well
    assert FieldOptionsProcessor.encode_type(Google.Protobuf.Timestamp, dt, extype: "NaiveDateTime.t") == output

    # Cannot encode NaiveDateTime as DateTime, missing timezone info.
    assert_raise FunctionClauseError, fn ->
      FieldOptionsProcessor.encode_type(Google.Protobuf.Timestamp, ndt, extype: "DateTime.t")
    end
  end

  test "encoding and decoding timestamp different timezone" do
    dt = %DateTime{year: 2017, month: 11, day: 7, zone_abbr: "CET",
      hour: 11, minute: 45, second: 18, microsecond: {123456, 6},
      utc_offset: 3600, std_offset: 0, time_zone: "Europe/Paris"
    }

    result =
      Google.Protobuf.Timestamp
      |> FieldOptionsProcessor.encode_type(dt, extype: "DateTime.t")
      |> FieldOptionsProcessor.decode_type(Google.Protobuf.Timestamp, extype: "DateTime.t")

    # They are not equal - timezone has been converted to utc
    refute dt == result

    assert "Europe/Paris" = dt.time_zone()
    assert "Etc/UTC" = result.time_zone()

    # But they are the equivalent time (at least in the past)
    assert DateTime.diff(dt, result) == 0

    dt1 = DateTime.from_unix!(1_464_096_368)

    result1 =
      Google.Protobuf.Timestamp
      |> FieldOptionsProcessor.encode_type(dt1, extype: "DateTime.t")
      |> FieldOptionsProcessor.decode_type(Google.Protobuf.Timestamp, extype: "DateTime.t")

    # They are not equal result1 has more precision than dt1
    refute dt1 == result1

    # Are equivalent
    assert DateTime.diff(dt1, result1) == 0

    # Set precision to microseconds
    dt2 = DateTime.from_unix!(1_464_096_368, :microsecond)

    result2 =
      Google.Protobuf.Timestamp
      |> FieldOptionsProcessor.encode_type(dt2, extype: "DateTime.t")
      |> FieldOptionsProcessor.decode_type(Google.Protobuf.Timestamp, extype: "DateTime.t")

    # They are equal
    assert dt2 == result2
  end
end
