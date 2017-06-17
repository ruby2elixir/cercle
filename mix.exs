defmodule CercleApi.Mixfile do
  use Mix.Project

  def project do
    [app: :cercleApi,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     test_coverage: [tool: ExCov],
     preferred_cli_env: [
       "cov": :test,
       "cov.detail": :test
     ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {CercleApi, []},
     applications: [
       :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger,
       :gettext, :phoenix_ecto, :postgrex, :ex_aws, :hackney, :httpoison, :tzdata,
       :csv, :ex_csv, :uuid, :arc_ecto, :rollbax
     ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.4"},
     {:phoenix_pubsub, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_ecto, ">= 3.0.0"},
     {:db_connection, ">= 0.0.0"},
     {:phoenix_html, "~> 2.9.2"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:mailman, "~> 0.2.2"},
     {:arc, "~> 0.8.0"},
     {:ex_aws, "~> 1.1"},
     {:httpoison, "~> 0.7"},
     {:poison, "~> 2.2"},
     {:hackney, "~> 1.7.0"},
     {:sweet_xml, "~> 0.6.5"},
     {:arc_ecto, "~> 0.7.0"},
     {:timex, "~> 3.1.8"},
     {:gettext, "~> 0.13.0"},
     {:basic_auth, "~> 2.0.0"},
     {:csv, "~> 1.4.2"},
     {:ex_csv, "~> 0.1.5"},
     {:uuid, "~> 1.1"},
     {:tzdata, "~> 0.5.8"},
     {:guardian, "~> 0.14.2"},
     {:canary, "~> 1.1.0"},
     {:canada, "~> 1.0.1"},
     {:comeonin, "~> 2.5"},
     {:cipher, ">= 1.3.0"},
     {:rummage_ecto, "~> 1.1.0"},
     {:rollbax, "~> 0.8.2"},
     {:ex_oauth2_provider, "~> 0.2.0"},

     # dev
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:sobelow, "~> 0.3", only: [:dev]},

     # test
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:ex_machina, "~> 2.0", only: [:test]},
     {:excov, "~> 0.1", only: :test},
     {:excov_reporter_console, "~> 0.1", only: :test}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
