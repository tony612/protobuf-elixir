defmodule Protobuf.Protoc.ExtTest.Foo do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          a: String.t()
        }
  defstruct a: nil

  field :a, 1, optional: true, type: :string
end
