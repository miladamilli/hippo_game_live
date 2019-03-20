# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :hippo_game_live, HippoGameLiveWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wysW1GnsI4Y5fTsjQlwG3acqpWHpdQcMOs3hV9327Iz970U+VxXtjN5kLzQ8Vchc",
  render_errors: [view: HippoGameLiveWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HippoGameLive.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "ntxqMSKWNsk8soz6wEOleLByRS78OkhY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :phoenix, template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
