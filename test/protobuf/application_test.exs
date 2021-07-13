defmodule Protobuf.ApplicationTest do
  use ExUnit.Case, async: false

  test "unloads all extensions on shutdown and reloads upon start" do
    assert loaded_extensions() > 0

    assert :ok = Application.stop(:protobuf)
    assert loaded_extensions() == 0

    assert :ok = Application.start(:protobuf)
    assert loaded_extensions() > 0
  end

  defp loaded_extensions do
    Enum.count(:persistent_term.get(), &match?({{Protobuf.Extension, _, _}, _}, &1))
  end
end
