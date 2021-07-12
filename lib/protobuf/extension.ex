defmodule Protobuf.Extension do
  @moduledoc """
  [Extensions](https://developers.google.com/protocol-buffers/docs/proto#extensions)
  let you set extra fields for previously defined messages(even for messages in other packages)
  without changing the original message.

  **This is an experimental feature**, to use it, Erlang should be >= 21.2 because `:persistent_term`
  is used and config should be set:

      # Without this, modules won't be scanned to get extensions metadata.
      # Functions like `get_extension` and `put_extension` still exist, but they don't work.
      config :protobuf, extensions: :enabled

  To know what extensions a module has and what are their metadata, all modules are scanned
  when :protobuf application starts. Now `:persistent_term` is used to store the runtime information.
  The runtime info is used to validate the extension when calling `put_extension` and decode/encode
  the extensions.

  ## Examples

      # protoc should be used to generate the code instead of writing by hand.
      defmodule Foo do
        use Protobuf, syntax: :proto2

        extensions([{100, 101}, {1000, 536_870_912}])
      end

      # This module is generated for all "extend" calls in one file.
      # This module is needed in `*_extension` function because the field name is scoped
      # in the proto file.
      defmodule Ext.PbExtension do
        use Protobuf, syntax: :proto2

        extend Foo, :my_custom, 1047, optional: true, type: :string
      end

      foo = Foo.new()
      Foo.put_extension(foo, Ext.PbExtension, :my_custom, "Custom field")
      Foo.get_extension(foo, Ext.PbExtension, :my_custom)
  """
  alias Protobuf.GlobalStore

  @doc "The actual function for `put_extension`"
  @spec put(module, map, module, atom, any) :: map
  def put(mod, struct, extension_mod, field, value) do
    key = {mod, field}

    case extension_mod.__protobuf_info__(:extension_props) do
      %{name_to_tag: %{^key => _}} ->
        case struct do
          %{__pb_extensions__: es} ->
            Map.put(struct, :__pb_extensions__, Map.put(es, {extension_mod, field}, value))

          _ ->
            Map.put(struct, :__pb_extensions__, %{{extension_mod, field} => value})
        end

      _ ->
        raise Protobuf.ExtensionNotFound,
          message: "Extension #{extension_mod}##{field} is not found"
    end
  end

  @doc "The actual function for `get_extension`"
  @spec get(map, module, atom, any) :: any
  def get(struct, extension_mod, field, default) do
    key = {extension_mod, field}

    case struct do
      %{__pb_extensions__: %{^key => val}} ->
        val

      %{} ->
        default
    end
  end

  @doc false
  def get_extension_props(extendee, ext_mod, field) do
    index = {extendee, field}
    ext_props = ext_mod.__protobuf_info__(:extension_props)

    case ext_props.name_to_tag do
      %{^index => tag_idx} ->
        case ext_props.extensions do
          %{^tag_idx => props} ->
            props

          _ ->
            nil
        end

      _ ->
        nil
    end
  end

  @doc false
  def get_extension_props_by_tag(extendee, tag) do
    case GlobalStore.get({Protobuf.Extension, extendee, tag}, nil) do
      nil ->
        nil

      mod ->
        index = {extendee, tag}

        case mod.__protobuf_info__(:extension_props).extensions do
          %{^index => props} ->
            {mod, props}

          _ ->
            nil
        end
    end
  end

  @doc false
  def cal_extensions(mods) do
    for mod <- mods,
        to_string(mod) =~ ~r/\.PbExtension$/,
        Code.ensure_loaded?(mod),
        function_exported?(mod, :__protobuf_info__, 1),
        %{extensions: extensions} = mod.__protobuf_info__(:extension_props) do
      Enum.each(extensions, fn {_, ext} ->
        fnum = ext.field_props.fnum
        fnum_key = {Protobuf.Extension, ext.extendee, fnum}

        if GlobalStore.get(fnum_key, nil) do
          raise "Extension #{inspect(ext.extendee)}##{fnum} already exists"
        end

        GlobalStore.put(fnum_key, mod)
      end)
    end
  end
end
