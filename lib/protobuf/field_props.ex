defmodule Protobuf.FieldProps do
  @moduledoc false

  @type t :: %__MODULE__{
          fnum: integer,
          name: String.t(),
          name_atom: atom,
          json_name: String.t(),
          wire_type: 0..5,
          type: atom,
          default: any,
          oneof: non_neg_integer | nil,
          required?: boolean,
          optional?: boolean,
          repeated?: boolean,
          enum?: boolean,
          embedded?: boolean,
          packed?: boolean,
          map?: boolean,
          deprecated?: boolean,
          encoded_fnum: iodata,
          extensions: map
        }
  defstruct fnum: nil,
            name: nil,
            name_atom: nil,
            json_name: nil,
            wire_type: nil,
            type: nil,
            default: nil,
            oneof: nil,
            required?: false,
            optional?: false,
            repeated?: false,
            enum?: false,
            embedded?: false,
            packed?: nil,
            map?: false,
            deprecated?: false,
            encoded_fnum: nil,
            extensions: %{}
end
