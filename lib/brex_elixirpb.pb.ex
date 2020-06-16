defmodule Brex.Elixirpb.FieldOptions do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          extype: String.t()
        }
  defstruct [:extype]

  field :extype, 1, optional: true, type: :string
end

defmodule Brex.Elixirpb.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto2

  extend Google.Protobuf.FieldOptions, :field, 65007,
    optional: true,
    type: Brex.Elixirpb.FieldOptions
end
