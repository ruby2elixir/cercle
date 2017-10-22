use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cercleApi, CercleApi.Endpoint,
  http: [port: 4001],
  server: true
config :cercleApi, :sql_sandbox, true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cercleApi, CercleApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "cercleapi_test",
  hostname: "localhost",
  ownership_timeout: 60_000,
  timeout: 60_000,
  pool_timeout: 60_000,
  pool: Ecto.Adapters.SQL.Sandbox

# Guardian configuration
config :guardian, Guardian,
  secret_key: "W9cDv9fjPtsYv2gItOcFb5PzmRzqGkrOsJGmby0KpBOlHJIlhxMKFmIlcCG9PVFQ"

config :cercleApi, basic_auth: [
    username: "admin",
    password: "admin",
    realm: "Admin Area"
  ]
config :rollbax,
  access_token: "",
  environment: "test",
  enabled: :log

config :arc,
  storage: Arc.Storage.Local

config :excov,
  :reporters, [
    ExCov.Reporter.Console
  ]

config :excov, ExCov.Reporter.Console,
  show_summary: true,
  show_detail: false

config :httpoison, timeout: 6000
config :wallaby,
  driver: Wallaby.Experimental.Chrome,
  hackney_options: [timeout: :infinity, recv_timeout: :infinity],
  chrome: [
    headless: true
  ],
  screenshot_on_failure: true

config :inbound_hook,
  token: "test123"
