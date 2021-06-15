defmodule Mix.Tasks.Protobuf do
  use Mix.Task

  def run(args) do
    Protobuf.Protoc.CLI.main(args)
  end
end
