defmodule Protobuf.Mixfile do
  use Mix.Project

  @version "0.8.0-beta.1"

  def project do
    [
      app: :protobuf,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      dialyzer: [plt_add_apps: [:mix, :jason]],
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      escript: escript(Mix.env()),
      description: description(),
      package: package(),
      aliases: aliases(),
      preferred_cli_env: ["test.integration": :test]
    ]
  end

  def application do
    [
      mod: {Protobuf.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "test/protobuf/protoc/proto_gen"]
  defp elixirc_paths(:conformance), do: ["lib", "conformance"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.2", optional: true},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:stream_data, "~> 0.5.0", only: [:dev, :test]}
    ]
  end

  defp escript(:conformance),
    do: [main_module: Conformance.Protobuf.Runner, name: "conformance_client"]

  defp escript(_), do: [main_module: Protobuf.Protoc.CLI, name: "protoc-gen-elixir"]

  defp description do
    "A pure Elixir implementation of Google Protobuf."
  end

  defp package do
    [
      maintainers: ["Bing Han"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/tony612/protobuf-elixir"},
      files:
        ~w(mix.exs README.md lib/google lib/protobuf lib/*.ex src LICENSE priv/templates .formatter.exs)
    ]
  end

  defp aliases do
    ["test.integration": &run_integration_tests/1]
  end

  defp run_integration_tests(args) do
    IO.puts("==> make clean")
    Mix.shell().cmd("make clean")

    IO.puts("==> make gen-protos")
    Mix.shell().cmd("make gen-protos")

    args = ["--only", "integration" | args]
    args = if IO.ANSI.enabled?(), do: ["--color" | args], else: ["--no-color" | args]

    IO.puts("==> mix test #{Enum.join(args, " ")}")
    Mix.Task.run("test", args)
  end
end
