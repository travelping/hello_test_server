defmodule HelloTestServerTest do
  use ExUnit.Case
  doctest HelloTestServer

  setup_all do
    :meck.new(Application, [:passthrough])
    :meck.expect(Application, :app_dir, fn(:hello_test_server, "priv/replies") -> "test/replies" end)
    on_exit fn ->
      :meck.unload
    end
  end

  test "ping" do
    assert {:ok, "pong"} == HelloTestServer.client()
    assert {:ok, "pong"} == HelloTestServer.client("Server.ping", %{"sleep" => 100})
    assert {:ok, "pong"} == HelloTestServer.client("Server.ping", %{"rsleep" => "100"})
  end

  test "unknown method" do
    assert {:ok, "not_found"} == HelloTestServer.client("unknown.method")
  end

  test "known method" do
    assert {:ok, %{"a" => "ok"}} == HelloTestServer.client("foo.foo")
  end

  test "known method with round robin" do
    {:ok, %{"a" => first}} = HelloTestServer.client("foo.bar")
    second = case first do
      1 -> 2
      2 -> 1
    end
    assert {:ok, %{"a" => second}} == HelloTestServer.client("foo.bar")
    assert {:ok, %{"a" => first}}== HelloTestServer.client("foo.bar")
    assert {:ok, %{"a" => second}} == HelloTestServer.client("foo.bar")
  end

  test "extended mode" do
    assert {:ok, %{"error" => "unknown"}} == HelloTestServer.client("foo.bar.extended", %{})
    assert {:ok, "response"} == HelloTestServer.client("foo.bar.extended", %{key: 1})
    assert {:ok, "response2"} == HelloTestServer.client("foo.bar.extended", %{key: 2})
  end
end
