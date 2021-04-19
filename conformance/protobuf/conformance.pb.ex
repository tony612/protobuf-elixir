defmodule Conformance.WireFormat do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :UNSPECIFIED | :PROTOBUF | :JSON | :JSPB | :TEXT_FORMAT

  field :UNSPECIFIED, 0
  field :PROTOBUF, 1
  field :JSON, 2
  field :JSPB, 3
  field :TEXT_FORMAT, 4
end

defmodule Conformance.TestCategory do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t ::
          integer
          | :UNSPECIFIED_TEST
          | :BINARY_TEST
          | :JSON_TEST
          | :JSON_IGNORE_UNKNOWN_PARSING_TEST
          | :JSPB_TEST
          | :TEXT_FORMAT_TEST

  field :UNSPECIFIED_TEST, 0
  field :BINARY_TEST, 1
  field :JSON_TEST, 2
  field :JSON_IGNORE_UNKNOWN_PARSING_TEST, 3
  field :JSPB_TEST, 4
  field :TEXT_FORMAT_TEST, 5
end

defmodule Conformance.FailureSet do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          failure: [String.t()]
        }
  defstruct [:failure]

  field :failure, 1, repeated: true, type: :string
end

defmodule Conformance.ConformanceRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          payload: {atom, any},
          requested_output_format: Conformance.WireFormat.t(),
          message_type: String.t(),
          test_category: Conformance.TestCategory.t(),
          jspb_encoding_options: Conformance.JspbEncodingConfig.t() | nil,
          print_unknown_fields: boolean
        }
  defstruct [
    :payload,
    :requested_output_format,
    :message_type,
    :test_category,
    :jspb_encoding_options,
    :print_unknown_fields
  ]

  oneof :payload, 0
  field :protobuf_payload, 1, type: :bytes, oneof: 0
  field :json_payload, 2, type: :string, oneof: 0
  field :jspb_payload, 7, type: :string, oneof: 0
  field :text_payload, 8, type: :string, oneof: 0
  field :requested_output_format, 3, type: Conformance.WireFormat, enum: true
  field :message_type, 4, type: :string
  field :test_category, 5, type: Conformance.TestCategory, enum: true
  field :jspb_encoding_options, 6, type: Conformance.JspbEncodingConfig
  field :print_unknown_fields, 9, type: :bool
end

defmodule Conformance.ConformanceResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result: {atom, any}
        }
  defstruct [:result]

  oneof :result, 0
  field :parse_error, 1, type: :string, oneof: 0
  field :serialize_error, 6, type: :string, oneof: 0
  field :runtime_error, 2, type: :string, oneof: 0
  field :protobuf_payload, 3, type: :bytes, oneof: 0
  field :json_payload, 4, type: :string, oneof: 0
  field :skipped, 5, type: :string, oneof: 0
  field :jspb_payload, 7, type: :string, oneof: 0
  field :text_payload, 8, type: :string, oneof: 0
end

defmodule Conformance.JspbEncodingConfig do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          use_jspb_array_any_format: boolean
        }
  defstruct [:use_jspb_array_any_format]

  field :use_jspb_array_any_format, 1, type: :bool
end
