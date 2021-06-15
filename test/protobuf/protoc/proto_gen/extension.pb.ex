defmodule Protobuf.Protoc.ExtTest.Foo do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          a: String.t(),
          b: String.t(),
          c: String.t()
        }
  defstruct [:a, :b, :c]

  field :a, 1, optional: true, type: :string

  field :b, 2,
    optional: true,
    type: :string,
    extensions: %{{Mypkg.PbExtension, :myopt_bool} => true}

  field :c, 3,
    optional: true,
    type: :string,
    extensions: %{{Mypkg.PbExtension, :myopt_string} => "test"}
end
