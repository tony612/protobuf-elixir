defmodule Protobuf.MessageProps do
  @moduledoc false

  alias Protobuf.FieldProps

  @type t :: %__MODULE__{
          ordered_tags: [integer],
          tags_map: %{integer => integer},
          field_props: %{integer => FieldProps.t},
          field_tags: %{atom => integer},
          repeated_fields: [atom],
          embedded_fields: [atom],
          syntax: atom,
          oneof: [{atom, non_neg_integer}],
          enum?: boolean,
          extendable?: boolean,
          map?: boolean,
          extension_range: [{non_neg_integer, non_neg_integer}]
        }
  defstruct ordered_tags: [],
            tags_map: %{},
            field_props: %{},
            field_tags: %{},
            repeated_fields: [],
            embedded_fields: [],
            syntax: :proto2,
            oneof: [],
            enum?: false,
            extendable?: false,
            map?: false,
            extension_range: []
end
