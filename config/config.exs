# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.
# Sample configuration:
#
#     config :logger,
#       level: :info
#
#     config :logger, :console,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
config :hello_test_server,
    listen: 'zmq-tcp://127.0.0.1:26000',
    respond_path: "priv/replies",
    run_script: false

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
metricman_config = "deps/metricman/config/config.exs"
if File.exists? metricman_config do
  import_config "../" <> metricman_config
end
