defmodule Mix.Tasks.Protobuf.Conformance do
  use Mix.Task

  @impl Mix.Task
  @spec run(any) :: any
  @shortdoc "runs the Google-provided conformance test suite"
  def run(args) do
    with {options, _, []} <-
           OptionParser.parse(args, strict: [runner: :string, verbose: :boolean]),
         {:ok, runner} <- Keyword.fetch(options, :runner),
         verbose <- Keyword.get(options, :verbose, false),
         :ok <- Mix.Tasks.Escript.Build.run([]),
         0 <-
           Mix.shell().cmd("""
           #{runner} \
           #{if verbose, do: "--verbose"} \
           --enforce_recommended \
           --failure_list conformance/protobuf/exemptions.txt \
           ./conformance_client
           """) do
      :ok
    else
      _ -> :error
    end
  end
end
