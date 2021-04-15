defmodule My.Test.HatType do
  @moduledoc """
  The Comment, yadda yadda yadda
  More details
  """
  use Protobuf, enum: true, syntax: :proto2

  @typedoc """
  deliberately skipping 0
  """
  @type fedora :: :FEDORA

  @type fez :: :FEZ
  @type t :: integer | fedora() | fez()

  field :FEDORA, 1
  field :FEZ, 2
end

defmodule My.Test.Days do
  @moduledoc """
  This enum represents days of the week.
  """
  use Protobuf, enum: true, syntax: :proto2

  @type monday :: :MONDAY
  @type tuesday :: :TUESDAY

  @typedoc """
  same value as MONDAY
  """
  @type lundi :: :LUNDI

  @type t :: integer | monday() | tuesday() | lundi()

  field :MONDAY, 1
  field :TUESDAY, 2
  field :LUNDI, 1
end

defmodule My.Test.Request.Color do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type red :: :RED
  @type green :: :GREEN
  @type blue :: :BLUE
  @type t :: integer | red() | green() | blue()

  field :RED, 0
  field :GREEN, 1
  field :BLUE, 2
end

defmodule My.Test.Reply.Entry.Game do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type football :: :FOOTBALL
  @type tennis :: :TENNIS
  @type t :: integer | football() | tennis()

  field :FOOTBALL, 1
  field :TENNIS, 2
end

defmodule My.Test.Request.SomeGroup do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type group_field :: integer
  @type t :: %__MODULE__{
          group_field: group_field()
        }

  defstruct [:group_field]

  field :group_field, 9, optional: true, type: :int32
end

defmodule My.Test.Request.NameMappingEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto2

  @type key :: integer
  @type value :: String.t()
  @type t :: %__MODULE__{
          key: key(),
          value: value()
        }

  defstruct [:key, :value]

  field :key, 1, optional: true, type: :int32
  field :value, 2, optional: true, type: :string
end

defmodule My.Test.Request.MsgMappingEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto2

  @type key :: integer
  @type value :: My.Test.Reply.t() | nil
  @type t :: %__MODULE__{
          key: key(),
          value: value()
        }

  defstruct [:key, :value]

  field :key, 1, optional: true, type: :sint64
  field :value, 2, optional: true, type: My.Test.Reply
end

defmodule My.Test.Request do
  @moduledoc """
  This is a message that might be sent somewhere.
  """
  use Protobuf, syntax: :proto2

  @type key :: [integer]

  @typedoc """
  optional imp.ImportedMessage imported_message = 2;

  no default
  """
  @type hue :: My.Test.Request.Color.t()

  @type hat :: My.Test.HatType.t()

  @typedoc """
  optional imp.ImportedMessage.Owner owner = 6;
  """
  @type deadline :: float | :infinity | :negative_infinity | :nan

  @type somegroup :: any

  @typedoc """
  These foreign types are in imp2.proto,
  which is publicly imported by imp.proto.
   optional imp.PubliclyImportedMessage pub = 10;
   optional imp.PubliclyImportedEnum pub_enum = 13 [default=HAIR];

  This is a map field. It will generate map[int32]string.
  """
  @type name_mapping :: %{integer => String.t()}

  @typedoc """
  This is a map field whose value type is a message.
  """
  @type msg_mapping :: %{integer => My.Test.Reply.t() | nil}

  @type reset :: integer

  @typedoc """
  This field should not conflict with any getters.
  """
  @type get_key :: String.t()

  @type t :: %__MODULE__{
          key: key(),
          hue: hue(),
          hat: hat(),
          deadline: deadline(),
          somegroup: somegroup(),
          name_mapping: name_mapping(),
          msg_mapping: msg_mapping(),
          reset: reset(),
          get_key: get_key()
        }

  defstruct [
    :key,
    :hue,
    :hat,
    :deadline,
    :somegroup,
    :name_mapping,
    :msg_mapping,
    :reset,
    :get_key
  ]

  field :key, 1, repeated: true, type: :int64
  field :hue, 3, optional: true, type: My.Test.Request.Color, enum: true
  field :hat, 4, optional: true, type: My.Test.HatType, default: :FEDORA, enum: true
  field :deadline, 7, optional: true, type: :float, default: "inf"
  field :somegroup, 8, optional: true, type: :group
  field :name_mapping, 14, repeated: true, type: My.Test.Request.NameMappingEntry, map: true
  field :msg_mapping, 15, repeated: true, type: My.Test.Request.MsgMappingEntry, map: true
  field :reset, 12, optional: true, type: :int32
  field :get_key, 16, optional: true, type: :string
end

defmodule My.Test.Reply.Entry do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type key_that_needs_1234camel_casing :: integer
  @type value :: integer
  @type _my_field_name_2 :: integer
  @type t :: %__MODULE__{
          key_that_needs_1234camel_CasIng: key_that_needs_1234camel_casing(),
          value: value(),
          _my_field_name_2: _my_field_name_2()
        }

  defstruct [:key_that_needs_1234camel_CasIng, :value, :_my_field_name_2]

  field :key_that_needs_1234camel_CasIng, 1, required: true, type: :int64
  field :value, 2, optional: true, type: :int64, default: 7
  field :_my_field_name_2, 3, optional: true, type: :int64
end

defmodule My.Test.Reply do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type found :: [My.Test.Reply.Entry.t()]
  @type compact_keys :: [integer]
  @type __pb_extensions__ :: map
  @type t :: %__MODULE__{
          found: found(),
          compact_keys: compact_keys()
        }

  defstruct [:found, :compact_keys, :__pb_extensions__]

  field :found, 1, repeated: true, type: My.Test.Reply.Entry
  field :compact_keys, 2, repeated: true, type: :int32, packed: true

  extensions [{100, 536_870_912}]
end

defmodule My.Test.OtherBase do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type name :: String.t()
  @type __pb_extensions__ :: map
  @type t :: %__MODULE__{
          name: name()
        }

  defstruct [:name, :__pb_extensions__]

  field :name, 1, optional: true, type: :string

  extensions [{100, 536_870_912}]
end

defmodule My.Test.ReplyExtensions do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{}

  defstruct []
end

defmodule My.Test.OtherReplyExtensions do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type key :: integer
  @type t :: %__MODULE__{
          key: key()
        }

  defstruct [:key]

  field :key, 1, optional: true, type: :int32
end

defmodule My.Test.OldReply do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{__pb_extensions__: map}

  defstruct [:__pb_extensions__]

  extensions [{100, 2_147_483_647}]
end

defmodule My.Test.Communique.SomeGroup do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type member :: String.t()
  @type t :: %__MODULE__{
          member: member()
        }

  defstruct [:member]

  field :member, 15, optional: true, type: :string
end

defmodule My.Test.Communique.Delta do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{}

  defstruct []
end

defmodule My.Test.Communique do
  use Protobuf, syntax: :proto2

  @type make_me_cry :: boolean
  @type number_ :: integer
  @type name :: String.t()
  @type data :: binary
  @type temp_c :: float | :infinity | :negative_infinity | :nan
  @type height :: float | :infinity | :negative_infinity | :nan
  @type today :: My.Test.Days.t()
  @type maybe :: boolean

  @typedoc """
  name will conflict with Delta below
  """
  @type delta :: integer

  @type msg :: My.Test.Reply.t() | nil
  @type somegroup :: any

  @typedoc """
  This is a oneof, called "union".
  """
  @type union ::
          {:number, number_()}
          | {:name, name()}
          | {:data, data()}
          | {:temp_c, temp_c()}
          | {:height, height()}
          | {:today, today()}
          | {:maybe, maybe()}
          | {:delta, delta()}
          | {:msg, msg()}
          | {:somegroup, somegroup()}
          | nil

  @type t :: %__MODULE__{
          make_me_cry: make_me_cry(),
          union: union()
        }

  defstruct [:union, :make_me_cry]

  oneof :union, 0

  field :make_me_cry, 1, optional: true, type: :bool
  field :number, 5, optional: true, type: :int32, oneof: 0
  field :name, 6, optional: true, type: :string, oneof: 0
  field :data, 7, optional: true, type: :bytes, oneof: 0
  field :temp_c, 8, optional: true, type: :double, oneof: 0
  field :height, 9, optional: true, type: :float, oneof: 0
  field :today, 10, optional: true, type: My.Test.Days, enum: true, oneof: 0
  field :maybe, 11, optional: true, type: :bool, oneof: 0
  field :delta, 12, optional: true, type: :sint32, oneof: 0
  field :msg, 13, optional: true, type: My.Test.Reply, oneof: 0
  field :somegroup, 14, optional: true, type: :group, oneof: 0
end

defmodule My.Test.Options do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type opt1 :: String.t()
  @type t :: %__MODULE__{
          opt1: opt1()
        }

  defstruct [:opt1]

  field :opt1, 1, optional: true, type: :string, deprecated: true
end

defmodule My.Test.PbExtension do
  @moduledoc false
  use Protobuf, syntax: :proto2

  extend My.Test.Reply, :tag, 103, optional: true, type: :string
  extend My.Test.Reply, :donut, 106, optional: true, type: My.Test.OtherReplyExtensions
  extend My.Test.Reply, :"ReplyExtensions.time", 101, optional: true, type: :double

  extend My.Test.Reply, :"ReplyExtensions.carrot", 105,
    optional: true,
    type: My.Test.ReplyExtensions

  extend My.Test.OtherBase, :"ReplyExtensions.donut", 101,
    optional: true,
    type: My.Test.ReplyExtensions
end
