defmodule Mypkg.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto2

  extend Google.Protobuf.FieldOptions, :myopt_bool, 100_000, optional: true, type: :bool

  extend Google.Protobuf.FieldOptions, :myopt_string, 100_001,
    optional: true,
    type: :string,
    default: "test"
end
