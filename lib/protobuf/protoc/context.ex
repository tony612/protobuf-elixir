defmodule Protobuf.Protoc.Context do
  @moduledoc false

  # Plugins passed by options
  defstruct plugins: [],

            ### All files scope

            # Mapping from file name to (mapping from type name to metadata, like elixir type name)
            # %{"example.proto" => %{".example.FooMsg" => %{type_name: "Example.FooMsg"}}}
            global_type_mapping: %{},

            ### One file scope

            # Package name
            package: nil,
            module_prefix: nil,
            syntax: nil,
            # Mapping from type_name to metadata. It's merged type mapping of dependencies files including itself
            # %{".example.FooMsg" => %{type_name: "Example.FooMsg"}}
            dep_type_mapping: %{},

            # For a message
            # Nested namespace when generating nested messages. It should be joined to get the full namespace
            namespace: [],

            # Include binary descriptors in the generated protobuf modules
            # And expose them via the `descriptor/0` function
            gen_descriptors?: false,

            # Elixirpb.FileOptions
            custom_file_options: %{},

            # Brex.Elixirpb.FieldOptions
            # Note: Right now just true or false, could have more complex values later
            custom_field_options?: false

  def cal_file_options(ctx, nil) do
    %{ctx | custom_file_options: %{}, module_prefix: ctx.package || ""}
  end

  def cal_file_options(ctx, options) do
    opts =
      case Google.Protobuf.FileOptions.get_extension(options, Elixirpb.PbExtension, :file) do
        nil ->
          %{}

        opts ->
          opts
      end

    module_prefix = Map.get(opts, :module_prefix) || (ctx.package || "")
    %{ctx | custom_file_options: opts, module_prefix: module_prefix}
  end
end
