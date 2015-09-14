defmodule Mix.Tasks.HellotestTest do
  use ExUnit.Case, async: true

  test "parse arguments correctly" do
    assert :help == Mix.Tasks.Hellotest.parse_args([])
    assert :help == Mix.Tasks.Hellotest.parse_args(["-h"])
    assert :help == Mix.Tasks.Hellotest.parse_args(["--help"])
    assert :help == Mix.Tasks.Hellotest.parse_args(["--listen","foo"])
    assert :help == Mix.Tasks.Hellotest.parse_args(["--path","foo"])
    assert [listen: "zmq-tcp://127.0.0.1:26000", path: "foo"] == Mix.Tasks.Hellotest.parse_args(["--listen", "zmq-tcp://127.0.0.1:26000", "--path","foo"])
  end

  @doc """
  Attention:
  Because this test changes application settings on the fly, other tests might break when these are not set properly
  """
  test "configuration setting" do
    Mix.Tasks.Hellotest.config_application([listen: "zmq-tcp://127.0.0.1:26000", path: "test/replies"])
    assert 'zmq-tcp://127.0.0.1:26000' == Application.get_env(:hello_test_server, :listen)
    assert "test/replies" == Application.get_env(:hello_test_server, :respond_path)

    assert catch_exit(Mix.Tasks.Hellotest.config_application(:help)) == :shutdown
  end
end
