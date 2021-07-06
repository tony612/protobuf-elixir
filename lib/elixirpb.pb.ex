defmodule Elixirpb.FileOptions do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          module_prefix: String.t()
        }
  defstruct module_prefix: nil

  field :module_prefix, 1, optional: true, type: :string
end

defmodule Elixirpb.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto2

  extend Google.Protobuf.FileOptions, :file, 1047, optional: true, type: Elixirpb.FileOptions
end
