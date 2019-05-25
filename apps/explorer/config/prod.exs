use Mix.Config

# Configures the database
config :explorer, Explorer.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: String.equivalent?(System.get_env("ECTO_USE_SSL") || "true", "true"),
  queue_target: String.to_integer(System.get_env("QUEUE_TARGET") || "50"),
  queue_interval: String.to_integer(System.get_env("QUEUE_INTERVAL") || "1000"),
  prepare: :unnamed,
  timeout: :timer.seconds(60)

# Our goal is to stay under `:queue_target` for `:queue_interval`.
# In case we can't reach that, then we double the :queue_target.
# If we go above that, then we start dropping messages.

# For example, by default our queue time is 50ms. If we stay above
# 50ms for a whole second (1000ms), we double the target to 100ms and we
# start dropping messages once it goes above the new limit.

# This allows us to better plan for overloads as we can refuse
# requests before they are sent to the database, which would
# otherwise increase the burden on the database, making the
# overload worse.

config :explorer, Explorer.Tracer, env: "production", disabled?: true

config :logger, :explorer,
  level: :info,
  path: Path.absname("logs/prod/explorer.log"),
  rotate: %{max_bytes: 52_428_800, keep: 19}

config :logger, :reading_token_functions,
  level: :debug,
  path: Path.absname("logs/prod/explorer/tokens/reading_functions.log"),
  metadata_filter: [fetcher: :token_functions],
  rotate: %{max_bytes: 52_428_800, keep: 19}

variant =
  if is_nil(System.get_env("ETHEREUM_JSONRPC_VARIANT")) do
    "parity"
  else
    System.get_env("ETHEREUM_JSONRPC_VARIANT")
    |> String.split(".")
    |> List.last()
    |> String.downcase()
  end

# Import variant specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "prod/#{variant}.exs"
