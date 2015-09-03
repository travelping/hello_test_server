defmodule HelloTestServer.Mixfile do
  use Mix.Project

  def project do
    [app: :hello_test_server,
     version: "0.1.0",
     test_coverage: [tool: Coverex.Task, coveralls: true],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(Mix.env)]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :elixir, :hello, :runtime_tools, :exrun, :metricman | (if Mix.env == :release do [:lager_journald_backend] else [] end)],
     mod: {HelloTestServer, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  @doc_deps [:earmark, :ex_doc]
  defp deps(:release) do
    Code.eval_file("mix.lock")
    |> elem(0)
    |> Enum.filter_map(&(not (&1 in @doc_deps)), fn({key, _}) -> {key, path: "deps/" <> "#{key}", override: true} end)
  end

  defp deps(_) do
    [{:lager, "~> 2.1.1", override: true},
     {:exrun, github: "liveforeverx/exrun"},
     {:exrm, "~> 0.18.0"},
     {:metricman, github: "surik/metricman"},
     {:jsx, github: "liveforeverx/jsx", branch: "mix_compile", override: true},
     {:hello, github: "travelping/hello", branch: "master"},
     {:coverex, "~> 1.4.1", only: :test},
     {:hackney, "~> 1.1.0", override: true}
   ]
  end
end
