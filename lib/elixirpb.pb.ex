defmodule Elixirpb.FileOptions do
  @moduledoc """
  File level options

  For example,
  option (elixirpb.file).module_prefix = "Foo";
  """
  use Protobuf, syntax: :proto2

  @typedoc """
  Specify a module prefix. This will override package name.
  For example, the package is "hello" and a message is "Request", the message
  will be "Hello.Request". But with module_prefix "Foo", the message will be
  "Foo.Request"
  """
  @type module_prefix :: String.t()

  @type t :: %__MODULE__{
          module_prefix: module_prefix()
        }

  defstruct [:module_prefix]

  field :module_prefix, 1, optional: true, type: :string
end

defmodule Elixirpb.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto2

  extend Google.Protobuf.FileOptions, :file, 1047, optional: true, type: Elixirpb.FileOptions
end
