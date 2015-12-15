defmodule HelloTestServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @rrtable :test_server_round_roubin_table
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(HelloTestServer.Worker, [arg1, arg2, arg3]),
    ]
    Hello.start_listener(url(), [], :hello_proto_jsonrpc, [], HelloTestServer.Router)
    Hello.bind(url(), __MODULE__)
    :ets.new(@rrtable, [:named_table, :public])
    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloTestServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def url(), do: Application.get_env(:hello_test_server, :listen)
  defp path(), do: Application.get_env(:hello_test_server, :respond_path)
  def name(), do: "ping/server"
  def router_key(), do: ""
  def validation(), do: __MODULE__
  def request(_, m, p), do: {:ok, m, p}

  def init(_identifier, _), do: {:ok, init_cache}

  def to_integer(intlike) do
    case intlike do
    intlike when is_integer(intlike) -> intlike
    intlike when is_binary(intlike) -> String.to_integer(intlike)
    end
  end

  def random(upper) do
    :crypto.rand_uniform(1, upper)
  end

  def handle_request(_context, "Server.ping", args, state) do
    case args do
      %{"rsleep" => rsleep} -> rsleep |> to_integer() |> random() |> :timer.sleep
      %{"sleep" => sleep}   -> sleep  |> to_integer() |> :timer.sleep
      _ -> nil
    end
    {:stop, :normal, {:ok, "pong"}, state}
  end

  def handle_request(_context, method, args, state) do
    counter = get_counter(method)
    {new_state, reply} = get_reply(state, args, method, counter)
    increase_counter(method)
    {:stop, :normal, reply, new_state}
  end

  def handle_info(_context, _message, state) do
    {:noreply, state}
  end

  def terminate(_context, _reason, _state) do
    :ok
  end

  def client(), do: client("Server.ping")
  def client(method), do: client(method, [])
  def client(method, params) do
    Hello.Client.start({:local, __MODULE__}, url(), [], [], [])
    Hello.Client.call(__MODULE__, {method, params, []})
  end

  defp init_cache() do
    if Application.get_env(:hello_test_server, :cached, false), do: %{}, else: :no_cache
  end

  defp get_reply(:no_cache, args, method, counter), do: {:no_cache, get_reply_no_cache(args, method, counter)}
  defp get_reply(cache, args, method, counter), do: get_reply_cached(cache, args, method, counter)

  defp get_reply_cached(cache, args, method, counter) do
    case Map.get(cache, method) do
      nil -> update_cache(cache, args, method, counter)
      l when is_list(l) -> {cache, choose_reply(l, counter)}
      reply = {:ok, _} -> {cache, reply}
    end
  end

  defp update_cache(cache, args, method, counter) do
    {path, dirname} = get_path_and_dir(method)
    new_entry =
      case File.ls(dirname) do
        {:ok, files} ->
          json_files = filter_json(dirname, files)
          for json_file <- json_files, do: {:ok, File.read!(json_file) |> :jsx.decode}
        _ ->
          scriptName = dirname <> ".ex"
          case File.exists?(scriptName) do
            true ->
              {reply, _} = File.read!(scriptName) |> Code.eval_string([params: args, path: path])
              {:ok, reply}
            false -> {:ok, "not_found"}
          end
      end
    get_reply_cached(Map.put(cache, method, new_entry), args, method, counter)
  end

  defp get_reply_no_cache(args, method, counter) do
    {path, dirname} = get_path_and_dir(method)
    case File.ls(dirname) do
      {:ok, files} ->
        reply = filter_json(dirname, files) |> choose_reply(counter) |> File.read!
        {:ok, :jsx.decode(reply)}
      _ ->
        scriptName = dirname <> ".ex"
        case File.exists?(scriptName) do
          true ->
            {reply, _} = File.read!(scriptName) |> Code.eval_string([params: args, path: path])
            {:ok, reply}
          false -> {:ok, "not_found"}
        end
    end
  end

  defp get_path_and_dir(method) do
    if Application.get_env(:hello_test_server, :run_script) do
      path = System.cwd! |> rel_path_join(path()) 
      dirname = path |> Path.join(method)
    else
      path = Application.app_dir(:hello_test_server, path()) 
      dirname = path |> Path.join(method)
    end
    {path, dirname}
  end

  defp get_counter(method) do
    case :ets.lookup(@rrtable, method) do
      [{^method, n}] -> n
      _ -> :ets.insert(@rrtable, {method, 0})
        0
    end
  end

  defp increase_counter(method), do: :ets.update_counter(@rrtable, method, {2, 1})

  defp filter_json(dirname, files) do
    for file <- files, Path.extname(file) == ".json" do
      Path.join(dirname, file)
    end
  end

  defp choose_reply(files, counter) do
    Enum.at(files, rem(counter, length(files)))
  end

  defp rel_path_join(path1, path2) do
    if Path.type(path2) == :absolute do
      path2
    else
      Path.join(path1, path2) |> Path.expand
    end
  end
end

defmodule HelloTestServer.Router do
  require Record
  Record.defrecordp(:context, Record.extract(:context, from_lib: "hello/include/hello.hrl"))

  def route(context(session_id: id), _request, _uri) do
    {:ok, HelloTestServer .name(), id}
  end
end
