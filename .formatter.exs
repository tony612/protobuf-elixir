
[
  inputs: ["mix.exs", "{config,lib,conformance,test}/**/*.{ex,exs}"],
  locals_without_parens: [field: 2, field: 3, oneof: 2, extend: 4, extensions: 1],
  export: [
    locals_without_parens: [field: 2, field: 3, oneof: 2, extend: 4, extensions: 1]
  ],
  import_deps: [:stream_data]
]
