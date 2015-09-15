defmodule Mix.Tasks.Hellotest do
  @moduledoc """
  Command line interface for changing parameters used by the HelloTestSever
  """
  use Mix.Task

  @version Mix.Project.config[:version]

  @shortdoc "Generate hellotestserver escript"
  @doc """
  Defines the command line behaviour
  """
  def run(argv) do
    argv
    |> parse_args
    |> config_application
    run_application
    no_halt
  end

  def parse_args(args) do
    parsed_args = OptionParser.parse(args, strict: [ help: :boolean,
                                                     listen: :string,
                                                     path: :string],
                                     aliases: [h: :help])
    case parsed_args do
      {[help: true], _, _}                -> :help
      {[], _, _}                          -> :help
      {args, _, _} when length(args) == 2 -> args
                                        _ -> :help
    end
  end

  def config_application(:help) do
    IO.puts """
    usage: hello_test_server [-h | --help] [--listen URL] [--path PATH]

    where URL in form of <protocol>://<host>[:<port>]
    Supported protocols are: zmq-tcp, zmq-tcp6, zmq-ipc, http
    It is possible to specify port as 0 or * to using only mdns registration

    PATH has to contain the possible requests in the format:
    <PATH>/request/response[1..n].json
    """
    exit(:shutdown)
  end

  def config_application(args) do
    Enum.map(args, fn keyword_arg -> config_arg keyword_arg end)
    Application.put_env(:hello_test_server, :run_script, true, persistent: true)
  end

  def run_application do
    Mix.Task.run("app.start", [])
    url = Application.get_env(:hello_test_server, :listen)
    path = Application.get_env(:hello_test_server, :respond_path)
    Mix.shell.info "HelloTestServer listening on URL: #{url} serving folder: #{path}"
  end

  defp config_arg({:listen, arg}) do
    Application.put_env(:hello_test_server, :listen, to_char_list(arg), persistent: true)
  end

  defp config_arg({:path, arg}) do
    Application.put_env(:hello_test_server, :respond_path, to_string(arg), persistent: true)
  end
  
  defp no_halt do
    unless iex_running?, do: :timer.sleep(:infinity)
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) && IEx.started?
  end
end
