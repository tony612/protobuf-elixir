defmodule My.Test.HatType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :FEDORA | :FEZ

  field :FEDORA, 1
  field :FEZ, 2
end

defmodule My.Test.Days do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :MONDAY | :TUESDAY | :LUNDI

  field :MONDAY, 1
  field :TUESDAY, 2
  field :LUNDI, 1
end

defmodule My.Test.Request.Color do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :RED | :GREEN | :BLUE

  field :RED, 0
  field :GREEN, 1
  field :BLUE, 2
end

defmodule My.Test.Reply.Entry.Game do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto2

  @type t :: integer | :FOOTBALL | :TENNIS

  field :FOOTBALL, 1
  field :TENNIS, 2
end

defmodule My.Test.Request.SomeGroup do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          group_field: integer
        }
  defstruct [:group_field]

  field :group_field, 9, optional: true, type: :int32
end

defmodule My.Test.Request.NameMappingEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto2

  @type t :: %__MODULE__{
          key: integer,
          value: String.t()
        }
  defstruct [:key, :value]

  field :key, 1, optional: true, type: :int32
  field :value, 2, optional: true, type: :string
end

defmodule My.Test.Request.MsgMappingEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto2

  @type t :: %__MODULE__{
          key: integer,
          value: My.Test.Reply.t() | nil
        }
  defstruct [:key, :value]

  field :key, 1, optional: true, type: :sint64
  field :value, 2, optional: true, type: My.Test.Reply
end

defmodule My.Test.Request do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          key: [integer],
          hue: My.Test.Request.Color.t(),
          hat: My.Test.HatType.t(),
          deadline: float | :infinity | :negative_infinity | :nan,
          somegroup: any,
          name_mapping: %{integer => String.t()},
          msg_mapping: %{integer => My.Test.Reply.t() | nil},
          reset: integer,
          get_key: String.t()
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

  @type t :: %__MODULE__{
          key_that_needs_1234camel_CasIng: integer,
          value: integer,
          _my_field_name_2: integer
        }
  defstruct [:key_that_needs_1234camel_CasIng, :value, :_my_field_name_2]

  field :key_that_needs_1234camel_CasIng, 1, required: true, type: :int64
  field :value, 2, optional: true, type: :int64, default: 7
  field :_my_field_name_2, 3, optional: true, type: :int64
end

defmodule My.Test.Reply do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          found: [My.Test.Reply.Entry.t()],
          compact_keys: [integer],
          __pb_extensions__: map
        }
  defstruct [:found, :compact_keys, :__pb_extensions__]

  field :found, 1, repeated: true, type: My.Test.Reply.Entry
  field :compact_keys, 2, repeated: true, type: :int32, packed: true

  extensions [{100, 536_870_912}]
end

defmodule My.Test.OtherBase do
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          name: String.t(),
          __pb_extensions__: map
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

  @type t :: %__MODULE__{
          key: integer
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

  @type t :: %__MODULE__{
          member: String.t()
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
  @moduledoc false
  use Protobuf, syntax: :proto2

  @type t :: %__MODULE__{
          union: {atom, any},
          make_me_cry: boolean
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

  @type t :: %__MODULE__{
          opt1: String.t(),
          opt2: String.t()
        }
  defstruct [:opt1, :opt2]

  field :opt1, 1, optional: true, type: :string, deprecated: true

  field :opt2, 2,
    optional: true,
    type: :string,
    extensions: %{{Mypkg.PbExtension, :myopt_bool} => true}
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
