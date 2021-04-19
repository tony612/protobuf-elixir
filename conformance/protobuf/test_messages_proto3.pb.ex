defmodule ProtobufTestMessages.Proto3.ForeignEnum do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :FOREIGN_FOO | :FOREIGN_BAR | :FOREIGN_BAZ

  field :FOREIGN_FOO, 0
  field :FOREIGN_BAR, 1
  field :FOREIGN_BAZ, 2
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :FOO | :BAR | :BAZ | :NEG

  field :FOO, 0
  field :BAR, 1
  field :BAZ, 2
  field :NEG, -1
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.AliasedEnum do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :ALIAS_FOO | :ALIAS_BAR | :ALIAS_BAZ | :QUX | :qux | :bAz

  field :ALIAS_FOO, 0
  field :ALIAS_BAR, 1
  field :ALIAS_BAZ, 2
  field :QUX, 2
  field :qux, 2
  field :bAz, 2
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          a: integer,
          corecursive: ProtobufTestMessages.Proto3.TestAllTypesProto3.t() | nil
        }
  defstruct [:a, :corecursive]

  field :a, 1, type: :int32
  field :corecursive, 2, type: ProtobufTestMessages.Proto3.TestAllTypesProto3
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt32Int32Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :int32
  field :value, 2, type: :int32
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt64Int64Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :int64
  field :value, 2, type: :int64
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapUint32Uint32Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: non_neg_integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :uint32
  field :value, 2, type: :uint32
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapUint64Uint64Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: non_neg_integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :uint64
  field :value, 2, type: :uint64
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSint32Sint32Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :sint32
  field :value, 2, type: :sint32
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSint64Sint64Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :sint64
  field :value, 2, type: :sint64
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapFixed32Fixed32Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: non_neg_integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :fixed32
  field :value, 2, type: :fixed32
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapFixed64Fixed64Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: non_neg_integer,
          value: non_neg_integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :fixed64
  field :value, 2, type: :fixed64
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSfixed32Sfixed32Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :sfixed32
  field :value, 2, type: :sfixed32
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSfixed64Sfixed64Entry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: integer
        }
  defstruct [:key, :value]

  field :key, 1, type: :sfixed64
  field :value, 2, type: :sfixed64
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt32FloatEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: float | :infinity | :negative_infinity | :nan
        }
  defstruct [:key, :value]

  field :key, 1, type: :int32
  field :value, 2, type: :float
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt32DoubleEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: integer,
          value: float | :infinity | :negative_infinity | :nan
        }
  defstruct [:key, :value]

  field :key, 1, type: :int32
  field :value, 2, type: :double
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapBoolBoolEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: boolean,
          value: boolean
        }
  defstruct [:key, :value]

  field :key, 1, type: :bool
  field :value, 2, type: :bool
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringStringEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: String.t()
        }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringBytesEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: binary
        }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :bytes
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringNestedMessageEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage.t() | nil
        }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringForeignMessageEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: ProtobufTestMessages.Proto3.ForeignMessage.t() | nil
        }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: ProtobufTestMessages.Proto3.ForeignMessage
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringNestedEnumEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum.t()
        }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum, enum: true
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringForeignEnumEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
          key: String.t(),
          value: ProtobufTestMessages.Proto3.ForeignEnum.t()
        }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: ProtobufTestMessages.Proto3.ForeignEnum, enum: true
end

defmodule ProtobufTestMessages.Proto3.TestAllTypesProto3 do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          oneof_field: {atom, any},
          optional_int32: integer,
          optional_int64: integer,
          optional_uint32: non_neg_integer,
          optional_uint64: non_neg_integer,
          optional_sint32: integer,
          optional_sint64: integer,
          optional_fixed32: non_neg_integer,
          optional_fixed64: non_neg_integer,
          optional_sfixed32: integer,
          optional_sfixed64: integer,
          optional_float: float | :infinity | :negative_infinity | :nan,
          optional_double: float | :infinity | :negative_infinity | :nan,
          optional_bool: boolean,
          optional_string: String.t(),
          optional_bytes: binary,
          optional_nested_message:
            ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage.t() | nil,
          optional_foreign_message: ProtobufTestMessages.Proto3.ForeignMessage.t() | nil,
          optional_nested_enum: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum.t(),
          optional_foreign_enum: ProtobufTestMessages.Proto3.ForeignEnum.t(),
          optional_aliased_enum: ProtobufTestMessages.Proto3.TestAllTypesProto3.AliasedEnum.t(),
          optional_string_piece: String.t(),
          optional_cord: String.t(),
          recursive_message: ProtobufTestMessages.Proto3.TestAllTypesProto3.t() | nil,
          repeated_int32: [integer],
          repeated_int64: [integer],
          repeated_uint32: [non_neg_integer],
          repeated_uint64: [non_neg_integer],
          repeated_sint32: [integer],
          repeated_sint64: [integer],
          repeated_fixed32: [non_neg_integer],
          repeated_fixed64: [non_neg_integer],
          repeated_sfixed32: [integer],
          repeated_sfixed64: [integer],
          repeated_float: [float | :infinity | :negative_infinity | :nan],
          repeated_double: [float | :infinity | :negative_infinity | :nan],
          repeated_bool: [boolean],
          repeated_string: [String.t()],
          repeated_bytes: [binary],
          repeated_nested_message: [
            ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage.t()
          ],
          repeated_foreign_message: [ProtobufTestMessages.Proto3.ForeignMessage.t()],
          repeated_nested_enum: [[ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum.t()]],
          repeated_foreign_enum: [[ProtobufTestMessages.Proto3.ForeignEnum.t()]],
          repeated_string_piece: [String.t()],
          repeated_cord: [String.t()],
          packed_int32: [integer],
          packed_int64: [integer],
          packed_uint32: [non_neg_integer],
          packed_uint64: [non_neg_integer],
          packed_sint32: [integer],
          packed_sint64: [integer],
          packed_fixed32: [non_neg_integer],
          packed_fixed64: [non_neg_integer],
          packed_sfixed32: [integer],
          packed_sfixed64: [integer],
          packed_float: [float | :infinity | :negative_infinity | :nan],
          packed_double: [float | :infinity | :negative_infinity | :nan],
          packed_bool: [boolean],
          packed_nested_enum: [[ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum.t()]],
          unpacked_int32: [integer],
          unpacked_int64: [integer],
          unpacked_uint32: [non_neg_integer],
          unpacked_uint64: [non_neg_integer],
          unpacked_sint32: [integer],
          unpacked_sint64: [integer],
          unpacked_fixed32: [non_neg_integer],
          unpacked_fixed64: [non_neg_integer],
          unpacked_sfixed32: [integer],
          unpacked_sfixed64: [integer],
          unpacked_float: [float | :infinity | :negative_infinity | :nan],
          unpacked_double: [float | :infinity | :negative_infinity | :nan],
          unpacked_bool: [boolean],
          unpacked_nested_enum: [[ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum.t()]],
          map_int32_int32: %{integer => integer},
          map_int64_int64: %{integer => integer},
          map_uint32_uint32: %{non_neg_integer => non_neg_integer},
          map_uint64_uint64: %{non_neg_integer => non_neg_integer},
          map_sint32_sint32: %{integer => integer},
          map_sint64_sint64: %{integer => integer},
          map_fixed32_fixed32: %{non_neg_integer => non_neg_integer},
          map_fixed64_fixed64: %{non_neg_integer => non_neg_integer},
          map_sfixed32_sfixed32: %{integer => integer},
          map_sfixed64_sfixed64: %{integer => integer},
          map_int32_float: %{integer => float | :infinity | :negative_infinity | :nan},
          map_int32_double: %{integer => float | :infinity | :negative_infinity | :nan},
          map_bool_bool: %{boolean => boolean},
          map_string_string: %{String.t() => String.t()},
          map_string_bytes: %{String.t() => binary},
          map_string_nested_message: %{
            String.t() => ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage.t() | nil
          },
          map_string_foreign_message: %{
            String.t() => ProtobufTestMessages.Proto3.ForeignMessage.t() | nil
          },
          map_string_nested_enum: %{
            String.t() => ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum.t()
          },
          map_string_foreign_enum: %{String.t() => ProtobufTestMessages.Proto3.ForeignEnum.t()},
          optional_bool_wrapper: Google.Protobuf.BoolValue.t() | nil,
          optional_int32_wrapper: Google.Protobuf.Int32Value.t() | nil,
          optional_int64_wrapper: Google.Protobuf.Int64Value.t() | nil,
          optional_uint32_wrapper: Google.Protobuf.UInt32Value.t() | nil,
          optional_uint64_wrapper: Google.Protobuf.UInt64Value.t() | nil,
          optional_float_wrapper: Google.Protobuf.FloatValue.t() | nil,
          optional_double_wrapper: Google.Protobuf.DoubleValue.t() | nil,
          optional_string_wrapper: Google.Protobuf.StringValue.t() | nil,
          optional_bytes_wrapper: Google.Protobuf.BytesValue.t() | nil,
          repeated_bool_wrapper: [Google.Protobuf.BoolValue.t()],
          repeated_int32_wrapper: [Google.Protobuf.Int32Value.t()],
          repeated_int64_wrapper: [Google.Protobuf.Int64Value.t()],
          repeated_uint32_wrapper: [Google.Protobuf.UInt32Value.t()],
          repeated_uint64_wrapper: [Google.Protobuf.UInt64Value.t()],
          repeated_float_wrapper: [Google.Protobuf.FloatValue.t()],
          repeated_double_wrapper: [Google.Protobuf.DoubleValue.t()],
          repeated_string_wrapper: [Google.Protobuf.StringValue.t()],
          repeated_bytes_wrapper: [Google.Protobuf.BytesValue.t()],
          optional_duration: Google.Protobuf.Duration.t() | nil,
          optional_timestamp: Google.Protobuf.Timestamp.t() | nil,
          optional_field_mask: Google.Protobuf.FieldMask.t() | nil,
          optional_struct: Google.Protobuf.Struct.t() | nil,
          optional_any: Google.Protobuf.Any.t() | nil,
          optional_value: Google.Protobuf.Value.t() | nil,
          repeated_duration: [Google.Protobuf.Duration.t()],
          repeated_timestamp: [Google.Protobuf.Timestamp.t()],
          repeated_fieldmask: [Google.Protobuf.FieldMask.t()],
          repeated_struct: [Google.Protobuf.Struct.t()],
          repeated_any: [Google.Protobuf.Any.t()],
          repeated_value: [Google.Protobuf.Value.t()],
          repeated_list_value: [Google.Protobuf.ListValue.t()],
          fieldname1: integer,
          field_name2: integer,
          _field_name3: integer,
          field__name4_: integer,
          field0name5: integer,
          field_0_name6: integer,
          fieldName7: integer,
          FieldName8: integer,
          field_Name9: integer,
          Field_Name10: integer,
          FIELD_NAME11: integer,
          FIELD_name12: integer,
          __field_name13: integer,
          __Field_name14: integer,
          field__name15: integer,
          field__Name16: integer,
          field_name17__: integer,
          Field_name18__: integer
        }
  defstruct [
    :oneof_field,
    :optional_int32,
    :optional_int64,
    :optional_uint32,
    :optional_uint64,
    :optional_sint32,
    :optional_sint64,
    :optional_fixed32,
    :optional_fixed64,
    :optional_sfixed32,
    :optional_sfixed64,
    :optional_float,
    :optional_double,
    :optional_bool,
    :optional_string,
    :optional_bytes,
    :optional_nested_message,
    :optional_foreign_message,
    :optional_nested_enum,
    :optional_foreign_enum,
    :optional_aliased_enum,
    :optional_string_piece,
    :optional_cord,
    :recursive_message,
    :repeated_int32,
    :repeated_int64,
    :repeated_uint32,
    :repeated_uint64,
    :repeated_sint32,
    :repeated_sint64,
    :repeated_fixed32,
    :repeated_fixed64,
    :repeated_sfixed32,
    :repeated_sfixed64,
    :repeated_float,
    :repeated_double,
    :repeated_bool,
    :repeated_string,
    :repeated_bytes,
    :repeated_nested_message,
    :repeated_foreign_message,
    :repeated_nested_enum,
    :repeated_foreign_enum,
    :repeated_string_piece,
    :repeated_cord,
    :packed_int32,
    :packed_int64,
    :packed_uint32,
    :packed_uint64,
    :packed_sint32,
    :packed_sint64,
    :packed_fixed32,
    :packed_fixed64,
    :packed_sfixed32,
    :packed_sfixed64,
    :packed_float,
    :packed_double,
    :packed_bool,
    :packed_nested_enum,
    :unpacked_int32,
    :unpacked_int64,
    :unpacked_uint32,
    :unpacked_uint64,
    :unpacked_sint32,
    :unpacked_sint64,
    :unpacked_fixed32,
    :unpacked_fixed64,
    :unpacked_sfixed32,
    :unpacked_sfixed64,
    :unpacked_float,
    :unpacked_double,
    :unpacked_bool,
    :unpacked_nested_enum,
    :map_int32_int32,
    :map_int64_int64,
    :map_uint32_uint32,
    :map_uint64_uint64,
    :map_sint32_sint32,
    :map_sint64_sint64,
    :map_fixed32_fixed32,
    :map_fixed64_fixed64,
    :map_sfixed32_sfixed32,
    :map_sfixed64_sfixed64,
    :map_int32_float,
    :map_int32_double,
    :map_bool_bool,
    :map_string_string,
    :map_string_bytes,
    :map_string_nested_message,
    :map_string_foreign_message,
    :map_string_nested_enum,
    :map_string_foreign_enum,
    :optional_bool_wrapper,
    :optional_int32_wrapper,
    :optional_int64_wrapper,
    :optional_uint32_wrapper,
    :optional_uint64_wrapper,
    :optional_float_wrapper,
    :optional_double_wrapper,
    :optional_string_wrapper,
    :optional_bytes_wrapper,
    :repeated_bool_wrapper,
    :repeated_int32_wrapper,
    :repeated_int64_wrapper,
    :repeated_uint32_wrapper,
    :repeated_uint64_wrapper,
    :repeated_float_wrapper,
    :repeated_double_wrapper,
    :repeated_string_wrapper,
    :repeated_bytes_wrapper,
    :optional_duration,
    :optional_timestamp,
    :optional_field_mask,
    :optional_struct,
    :optional_any,
    :optional_value,
    :repeated_duration,
    :repeated_timestamp,
    :repeated_fieldmask,
    :repeated_struct,
    :repeated_any,
    :repeated_value,
    :repeated_list_value,
    :fieldname1,
    :field_name2,
    :_field_name3,
    :field__name4_,
    :field0name5,
    :field_0_name6,
    :fieldName7,
    :FieldName8,
    :field_Name9,
    :Field_Name10,
    :FIELD_NAME11,
    :FIELD_name12,
    :__field_name13,
    :__Field_name14,
    :field__name15,
    :field__Name16,
    :field_name17__,
    :Field_name18__
  ]

  oneof :oneof_field, 0
  field :optional_int32, 1, type: :int32
  field :optional_int64, 2, type: :int64
  field :optional_uint32, 3, type: :uint32
  field :optional_uint64, 4, type: :uint64
  field :optional_sint32, 5, type: :sint32
  field :optional_sint64, 6, type: :sint64
  field :optional_fixed32, 7, type: :fixed32
  field :optional_fixed64, 8, type: :fixed64
  field :optional_sfixed32, 9, type: :sfixed32
  field :optional_sfixed64, 10, type: :sfixed64
  field :optional_float, 11, type: :float
  field :optional_double, 12, type: :double
  field :optional_bool, 13, type: :bool
  field :optional_string, 14, type: :string
  field :optional_bytes, 15, type: :bytes

  field :optional_nested_message, 18,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage

  field :optional_foreign_message, 19, type: ProtobufTestMessages.Proto3.ForeignMessage

  field :optional_nested_enum, 21,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum,
    enum: true

  field :optional_foreign_enum, 22, type: ProtobufTestMessages.Proto3.ForeignEnum, enum: true

  field :optional_aliased_enum, 23,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.AliasedEnum,
    enum: true

  field :optional_string_piece, 24, type: :string
  field :optional_cord, 25, type: :string
  field :recursive_message, 27, type: ProtobufTestMessages.Proto3.TestAllTypesProto3
  field :repeated_int32, 31, repeated: true, type: :int32
  field :repeated_int64, 32, repeated: true, type: :int64
  field :repeated_uint32, 33, repeated: true, type: :uint32
  field :repeated_uint64, 34, repeated: true, type: :uint64
  field :repeated_sint32, 35, repeated: true, type: :sint32
  field :repeated_sint64, 36, repeated: true, type: :sint64
  field :repeated_fixed32, 37, repeated: true, type: :fixed32
  field :repeated_fixed64, 38, repeated: true, type: :fixed64
  field :repeated_sfixed32, 39, repeated: true, type: :sfixed32
  field :repeated_sfixed64, 40, repeated: true, type: :sfixed64
  field :repeated_float, 41, repeated: true, type: :float
  field :repeated_double, 42, repeated: true, type: :double
  field :repeated_bool, 43, repeated: true, type: :bool
  field :repeated_string, 44, repeated: true, type: :string
  field :repeated_bytes, 45, repeated: true, type: :bytes

  field :repeated_nested_message, 48,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage

  field :repeated_foreign_message, 49,
    repeated: true,
    type: ProtobufTestMessages.Proto3.ForeignMessage

  field :repeated_nested_enum, 51,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum,
    enum: true

  field :repeated_foreign_enum, 52,
    repeated: true,
    type: ProtobufTestMessages.Proto3.ForeignEnum,
    enum: true

  field :repeated_string_piece, 54, repeated: true, type: :string
  field :repeated_cord, 55, repeated: true, type: :string
  field :packed_int32, 75, repeated: true, type: :int32, packed: true
  field :packed_int64, 76, repeated: true, type: :int64, packed: true
  field :packed_uint32, 77, repeated: true, type: :uint32, packed: true
  field :packed_uint64, 78, repeated: true, type: :uint64, packed: true
  field :packed_sint32, 79, repeated: true, type: :sint32, packed: true
  field :packed_sint64, 80, repeated: true, type: :sint64, packed: true
  field :packed_fixed32, 81, repeated: true, type: :fixed32, packed: true
  field :packed_fixed64, 82, repeated: true, type: :fixed64, packed: true
  field :packed_sfixed32, 83, repeated: true, type: :sfixed32, packed: true
  field :packed_sfixed64, 84, repeated: true, type: :sfixed64, packed: true
  field :packed_float, 85, repeated: true, type: :float, packed: true
  field :packed_double, 86, repeated: true, type: :double, packed: true
  field :packed_bool, 87, repeated: true, type: :bool, packed: true

  field :packed_nested_enum, 88,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum,
    enum: true,
    packed: true

  field :unpacked_int32, 89, repeated: true, type: :int32
  field :unpacked_int64, 90, repeated: true, type: :int64
  field :unpacked_uint32, 91, repeated: true, type: :uint32
  field :unpacked_uint64, 92, repeated: true, type: :uint64
  field :unpacked_sint32, 93, repeated: true, type: :sint32
  field :unpacked_sint64, 94, repeated: true, type: :sint64
  field :unpacked_fixed32, 95, repeated: true, type: :fixed32
  field :unpacked_fixed64, 96, repeated: true, type: :fixed64
  field :unpacked_sfixed32, 97, repeated: true, type: :sfixed32
  field :unpacked_sfixed64, 98, repeated: true, type: :sfixed64
  field :unpacked_float, 99, repeated: true, type: :float
  field :unpacked_double, 100, repeated: true, type: :double
  field :unpacked_bool, 101, repeated: true, type: :bool

  field :unpacked_nested_enum, 102,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum,
    enum: true

  field :map_int32_int32, 56,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt32Int32Entry,
    map: true

  field :map_int64_int64, 57,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt64Int64Entry,
    map: true

  field :map_uint32_uint32, 58,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapUint32Uint32Entry,
    map: true

  field :map_uint64_uint64, 59,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapUint64Uint64Entry,
    map: true

  field :map_sint32_sint32, 60,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSint32Sint32Entry,
    map: true

  field :map_sint64_sint64, 61,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSint64Sint64Entry,
    map: true

  field :map_fixed32_fixed32, 62,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapFixed32Fixed32Entry,
    map: true

  field :map_fixed64_fixed64, 63,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapFixed64Fixed64Entry,
    map: true

  field :map_sfixed32_sfixed32, 64,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSfixed32Sfixed32Entry,
    map: true

  field :map_sfixed64_sfixed64, 65,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapSfixed64Sfixed64Entry,
    map: true

  field :map_int32_float, 66,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt32FloatEntry,
    map: true

  field :map_int32_double, 67,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapInt32DoubleEntry,
    map: true

  field :map_bool_bool, 68,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapBoolBoolEntry,
    map: true

  field :map_string_string, 69,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringStringEntry,
    map: true

  field :map_string_bytes, 70,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringBytesEntry,
    map: true

  field :map_string_nested_message, 71,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringNestedMessageEntry,
    map: true

  field :map_string_foreign_message, 72,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringForeignMessageEntry,
    map: true

  field :map_string_nested_enum, 73,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringNestedEnumEntry,
    map: true

  field :map_string_foreign_enum, 74,
    repeated: true,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.MapStringForeignEnumEntry,
    map: true

  field :oneof_uint32, 111, type: :uint32, oneof: 0

  field :oneof_nested_message, 112,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedMessage,
    oneof: 0

  field :oneof_string, 113, type: :string, oneof: 0
  field :oneof_bytes, 114, type: :bytes, oneof: 0
  field :oneof_bool, 115, type: :bool, oneof: 0
  field :oneof_uint64, 116, type: :uint64, oneof: 0
  field :oneof_float, 117, type: :float, oneof: 0
  field :oneof_double, 118, type: :double, oneof: 0

  field :oneof_enum, 119,
    type: ProtobufTestMessages.Proto3.TestAllTypesProto3.NestedEnum,
    enum: true,
    oneof: 0

  field :optional_bool_wrapper, 201, type: Google.Protobuf.BoolValue
  field :optional_int32_wrapper, 202, type: Google.Protobuf.Int32Value
  field :optional_int64_wrapper, 203, type: Google.Protobuf.Int64Value
  field :optional_uint32_wrapper, 204, type: Google.Protobuf.UInt32Value
  field :optional_uint64_wrapper, 205, type: Google.Protobuf.UInt64Value
  field :optional_float_wrapper, 206, type: Google.Protobuf.FloatValue
  field :optional_double_wrapper, 207, type: Google.Protobuf.DoubleValue
  field :optional_string_wrapper, 208, type: Google.Protobuf.StringValue
  field :optional_bytes_wrapper, 209, type: Google.Protobuf.BytesValue
  field :repeated_bool_wrapper, 211, repeated: true, type: Google.Protobuf.BoolValue
  field :repeated_int32_wrapper, 212, repeated: true, type: Google.Protobuf.Int32Value
  field :repeated_int64_wrapper, 213, repeated: true, type: Google.Protobuf.Int64Value
  field :repeated_uint32_wrapper, 214, repeated: true, type: Google.Protobuf.UInt32Value
  field :repeated_uint64_wrapper, 215, repeated: true, type: Google.Protobuf.UInt64Value
  field :repeated_float_wrapper, 216, repeated: true, type: Google.Protobuf.FloatValue
  field :repeated_double_wrapper, 217, repeated: true, type: Google.Protobuf.DoubleValue
  field :repeated_string_wrapper, 218, repeated: true, type: Google.Protobuf.StringValue
  field :repeated_bytes_wrapper, 219, repeated: true, type: Google.Protobuf.BytesValue
  field :optional_duration, 301, type: Google.Protobuf.Duration
  field :optional_timestamp, 302, type: Google.Protobuf.Timestamp
  field :optional_field_mask, 303, type: Google.Protobuf.FieldMask
  field :optional_struct, 304, type: Google.Protobuf.Struct
  field :optional_any, 305, type: Google.Protobuf.Any
  field :optional_value, 306, type: Google.Protobuf.Value
  field :repeated_duration, 311, repeated: true, type: Google.Protobuf.Duration
  field :repeated_timestamp, 312, repeated: true, type: Google.Protobuf.Timestamp
  field :repeated_fieldmask, 313, repeated: true, type: Google.Protobuf.FieldMask
  field :repeated_struct, 324, repeated: true, type: Google.Protobuf.Struct
  field :repeated_any, 315, repeated: true, type: Google.Protobuf.Any
  field :repeated_value, 316, repeated: true, type: Google.Protobuf.Value
  field :repeated_list_value, 317, repeated: true, type: Google.Protobuf.ListValue
  field :fieldname1, 401, type: :int32
  field :field_name2, 402, type: :int32
  field :_field_name3, 403, type: :int32
  field :field__name4_, 404, type: :int32
  field :field0name5, 405, type: :int32
  field :field_0_name6, 406, type: :int32
  field :fieldName7, 407, type: :int32
  field :FieldName8, 408, type: :int32
  field :field_Name9, 409, type: :int32
  field :Field_Name10, 410, type: :int32
  field :FIELD_NAME11, 411, type: :int32
  field :FIELD_name12, 412, type: :int32
  field :__field_name13, 413, type: :int32
  field :__Field_name14, 414, type: :int32
  field :field__name15, 415, type: :int32
  field :field__Name16, 416, type: :int32
  field :field_name17__, 417, type: :int32
  field :Field_name18__, 418, type: :int32
end

defmodule ProtobufTestMessages.Proto3.ForeignMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          c: integer
        }
  defstruct [:c]

  field :c, 1, type: :int32
end
