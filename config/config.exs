# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :cercleApi, CercleApi.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "5u6j1+tiDr+fvgiBdD5FqK0ofhc6pzDmQQdDlZwBL+1UW2+KbWVrOOw2+RLfHnQQ",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: CercleApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :guardian, Guardian,
  issuer: "CercleApi",
  ttl: { 3, :days },
  verify_issuer: true,
  serializer: CercleApi.GuardianSerializer

config :canary,
  repo: CercleApi.Repo

config :cercleApi, ecto_repos: [CercleApi.Repo]

config :cipher, keyphrase: "testiekeyphraseforcipher",
  ivphrase: "testieivphraseforcipher"

config :rummage_ecto, Rummage.Ecto,
  default_repo: CercleApi.Repo,
  default_per_page: 100

config :ex_oauth2_provider, ExOauth2Provider,
  repo: Elixir.CercleApi.Repo,
  resource_owner: CercleApi.User,
  application_owner: CercleApi.AdminUser,
  use_refresh_token: true
