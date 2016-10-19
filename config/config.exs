use Mix.Config

config :distributed_kv, number_of_registries: 4
config :distributed_kv, api_port: 4001

import_config "#{Mix.env}.exs"
