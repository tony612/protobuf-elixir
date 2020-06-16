defmodule Ext.Nested do
  @moduledoc false
  use Protobuf, custom_field_options?: true, syntax: :proto3

  @type t :: %__MODULE__{
          my_timestamp: {atom, any}
        }
  defstruct [:my_timestamp]

  oneof :my_timestamp, 0

  field :dt, 1, type: Google.Protobuf.Timestamp, oneof: 0, options: [extype: "DateTime.t"]
  field :ndt, 2, type: Google.Protobuf.Timestamp, oneof: 0, options: [extype: "NaiveDateTime.t"]
end

defmodule Ext.MyMessage do
  @moduledoc false
  use Protobuf, custom_field_options?: true, syntax: :proto3

  @type t :: %__MODULE__{
          f1: float | nil,
          f2: float | nil,
          f3: integer | nil,
          f4: non_neg_integer | nil,
          f5: integer | nil,
          f6: non_neg_integer | nil,
          f7: boolean | nil,
          f8: String.t() | nil,
          f9: String.t() | nil,
          no_extype: Google.Protobuf.StringValue.t() | nil,
          repeated_field: [String.t()],
          normal1: non_neg_integer,
          normal2: String.t(),
          nested: Ext.Nested.t() | nil
        }
  defstruct [
    :f1,
    :f2,
    :f3,
    :f4,
    :f5,
    :f6,
    :f7,
    :f8,
    :f9,
    :no_extype,
    :repeated_field,
    :normal1,
    :normal2,
    :nested
  ]

  field :f1, 1, type: Google.Protobuf.DoubleValue, options: [extype: "float"]
  field :f2, 2, type: Google.Protobuf.FloatValue, options: [extype: "float"]
  field :f3, 3, type: Google.Protobuf.Int64Value, options: [extype: "integer"]
  field :f4, 4, type: Google.Protobuf.UInt64Value, options: [extype: "non_neg_integer"]
  field :f5, 5, type: Google.Protobuf.Int32Value, options: [extype: "integer"]
  field :f6, 6, type: Google.Protobuf.UInt32Value, options: [extype: "non_neg_integer"]
  field :f7, 7, type: Google.Protobuf.BoolValue, options: [extype: "boolean"]
  field :f8, 8, type: Google.Protobuf.StringValue, options: [extype: "String.t"]
  field :f9, 9, type: Google.Protobuf.BytesValue, options: [extype: "String.t()"]
  field :no_extype, 10, type: Google.Protobuf.StringValue

  field :repeated_field, 11,
    repeated: true,
    type: Google.Protobuf.StringValue,
    options: [extype: "String.t"]

  field :normal1, 12, type: :uint64
  field :normal2, 13, type: :string
  field :nested, 14, type: Ext.Nested
end
