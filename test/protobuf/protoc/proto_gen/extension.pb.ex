defmodule Protobuf.Protoc.ExtTest.Foo do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type a :: String.t()
  @type t :: %__MODULE__{
          a: a()
        }

  defstruct [:a]

  field :a, 1, optional: true, type: :string
end
