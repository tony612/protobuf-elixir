defmodule TestMsg do
  defmodule SyntaxOption do
    use Protobuf, syntax: :proto3
    defstruct []
  end

  defmodule Foo.Bar do
    use Protobuf, syntax: :proto3

    defstruct [:a, :b]

    field :a, 1, type: :int32
    field :b, 2, type: :string
  end

  defmodule EnumFoo do
    use Protobuf, enum: true, syntax: :proto3

    field :UNKNOWN, 0
    field :A, 1
    field :B, 2
    field :C, 4
  end

  defmodule MapFoo do
    use Protobuf, map: true, syntax: :proto3

    defstruct [:key, :value]
    field :key, 1, type: :string
    field :value, 2, type: :int32
  end

  defmodule Foo do
    use Protobuf, syntax: :proto3

    defstruct [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o, :p, :non_matched]

    field :a, 1, type: :int32
    field :b, 2, type: :fixed64
    field :c, 3, type: :string
    # 4 is skipped for testing
    field :d, 5, type: :float
    field :e, 6, type: Foo.Bar
    field :f, 7, type: :int32
    field :g, 8, repeated: true, type: :int32, packed: false
    field :h, 9, repeated: true, type: Foo.Bar
    field :i, 10, repeated: true, type: :int32
    field :j, 11, type: EnumFoo, enum: true
    field :k, 12, type: :bool
    field :l, 13, repeated: true, type: MapFoo, map: true
    field :m, 14, type: EnumFoo, enum: true
    field :n, 15, type: :double
    field :o, 16, repeated: true, type: EnumFoo, enum: true
    field :p, 17, type: :string, deprecated: true
    # Used for testing against same field name with different types(in Foo2)
    field :non_matched, 101, type: :string
  end

  defmodule Foo2 do
    use Protobuf, syntax: :proto2

    defstruct [:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :non_matched]

    field :a, 1, required: true, type: :int32
    field :b, 2, optional: true, type: :fixed64, default: 5
    field :c, 3, optional: true, type: :string
    # 4 is skipped for testing
    # field :d, 5, optional: true, type: :float
    field :e, 6, optional: true, type: Foo.Bar
    # field :f, 7, optional: true, type: :int32
    field :g, 8, repeated: true, type: :int32
    # field :h, 9, repeated: true, type: Foo.Bar
    field :i, 10, repeated: true, type: :int32, packed: true
    # field :j, 11, optional: true, type: EnumFoo, enum: true
    # field :k, 12, optioanl: true, type: :bool
    field :l, 13, repeated: true, type: MapFoo, map: true
    field :non_matched, 101, type: :int32, optional: true
  end

  defmodule Oneof do
    use Protobuf

    defstruct [:first, :second, :other]

    oneof :first, 0
    oneof :second, 1
    field :a, 1, optional: true, type: :int32, oneof: 0
    field :b, 2, optional: true, type: :string, oneof: 0
    field :c, 3, optional: true, type: :int32, oneof: 1
    field :d, 4, optional: true, type: :string, oneof: 1
    field :e, 6, optional: true, type: EnumFoo, enum: true, oneof: 0
    field :other, 5, optional: true, type: :string
  end

  defmodule OneofProto3 do
    use Protobuf, syntax: :proto3

    defstruct [:first, :second, :other]

    oneof :first, 0
    oneof :second, 1
    field :a, 1, optional: true, type: :int32, oneof: 0
    field :b, 2, optional: true, type: :string, oneof: 0
    field :c, 3, optional: true, type: :int32, oneof: 1
    field :d, 4, optional: true, type: :string, oneof: 1
    field :e, 6, type: EnumFoo, enum: true, oneof: 0
    field :other, 5, optional: true, type: :string
  end

  defmodule Parent do
    use Protobuf, syntax: :proto3
    defstruct [:child]
    field :child, 1, type: Parent.Child
  end

  defmodule Parent.Child do
    use Protobuf, syntax: :proto3
    defstruct [:parent]
    field :parent, 1, type: Parent
  end

  defmodule Link do
    use Protobuf, syntax: :proto3
    defstruct [:child, :value]
    field :child, 1, type: Link
    field :value, 2, type: :int32
  end

  defmodule Bar2.Enum do
    @moduledoc false
    use Protobuf, enum: true, syntax: :proto2

    field :a, 0
    field :b, 1
  end

  defmodule Bar2 do
    use Protobuf, syntax: :proto2

    field :a, 1, required: true, type: Bar2.Enum, enum: true
    field :b, 2, optional: true, type: Bar2.Enum, enum: true
  end

  defmodule Ext.EnumFoo do
    @moduledoc false
    use Protobuf, enum: true, syntax: :proto2

    @type t :: integer | :UNKNOWN | :A | :B | :C

    field :UNKNOWN, 0
    field :A, 1
    field :B, 2
    field :C, 4
  end

  defmodule Ext.Foo1 do
    @moduledoc false
    use Protobuf, syntax: :proto2

    @type t :: %__MODULE__{
            fa: non_neg_integer,
            __pb_extensions__: map
          }
    defstruct [:fa, :__pb_extensions__]

    field :fa, 1, optional: true, type: :uint32

    extensions([{100, 101}, {1000, 536_870_912}])
  end

  defmodule Ext.Foo2 do
    @moduledoc false
    use Protobuf, syntax: :proto2

    @type t :: %__MODULE__{
            fa: non_neg_integer,
            __pb_extensions__: map
          }
    defstruct [:fa, :__pb_extensions__]

    field :fa, 1, optional: true, type: :uint32

    extensions([{100, 101}, {1000, 536_870_912}])
  end

  defmodule Ext.Options do
    @moduledoc false
    use Protobuf, syntax: :proto2

    @type t :: %__MODULE__{
            a: String.t()
          }
    defstruct [:a]

    field :a, 1, optional: true, type: :string
  end

  defmodule Ext.Parent do
    @moduledoc false
    use Protobuf, syntax: :proto2

    @type t :: %__MODULE__{}
    defstruct []
  end

  defmodule Ext.PbExtension do
    @moduledoc false
    use Protobuf, syntax: :proto2

    extend Ext.Foo1, :foo, 1047, optional: true, type: Ext.Options
    extend Ext.Foo1, :foo2, 1049, repeated: true, type: :uint32
    extend Ext.Foo2, :bar, 1047, optional: true, type: :string
    extend Ext.Foo1, :"Parent.foo", 1048, optional: true, type: Ext.EnumFoo, enum: true
  end

  defmodule Ext.DualUseCase do
    @moduledoc false
    use Protobuf, syntax: :proto3

    @type t :: %__MODULE__{
            a: String.t() | nil,
            b: Google.Protobuf.StringValue.t() | nil
          }
    defstruct [:a, :b]

    field :a, 1, optional: true, type: Google.Protobuf.StringValue, options: [extype: "String.t"]
    field :b, 2, optional: true, type: Google.Protobuf.StringValue
  end

  defmodule Ext.DualNonUse do
    @moduledoc false
    use Protobuf, syntax: :proto3

    @type t :: %__MODULE__{
            a: String.t() | nil,
            b: Google.Protobuf.StringValue.t() | nil
          }
    defstruct [:a, :b]

    field :a, 1, optional: true, type: Google.Protobuf.StringValue
    field :b, 2, optional: true, type: Google.Protobuf.StringValue
  end
end
