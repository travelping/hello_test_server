defmodule HelloPingpong do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @decoder :hello_json
  @url 'zmq-tcp://127.0.0.1:26000'
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(HelloPingpong.Worker, [arg1, arg2, arg3]),
    ]
    :hello.start_service(__MODULE__, [])
    :hello.start_listener(@url, [], :hello_proto_jsonrpc, [decoder: @decoder], :hello_router)
    :hello.bind(@url, __MODULE__)
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloPingpong.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def name(), do: "ping/server"
  def router_key(), do: "Server"
  def validation(), do: __MODULE__
  def request(_, m, p), do: {:ok, m, p}

  def init(identifier, _), do: {:ok, 0}

  def handle_request(_context, "Server.ping", _args, state) do
    :crypto.rand_uniform(1, 1000) |> :timer.sleep
    {:stop, :normal, {:ok, "pong"}, state}
  end

  def handle_info(_context, _message, state) do
    {:noreply, state}
  end

  def terminate(_context, _reason, _state) do
    :ok
  end

  def client() do
    :hello_client.start({:local, __MODULE__}, 'zmq-tcp://127.0.0.1:26000', [], [decoder: @decoder], [])
    :hello_client.call(__MODULE__, {"Server.ping", [], []})
  end
end
