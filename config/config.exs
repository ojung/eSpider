use Mix.Config

config :logger, :console,
  format: "$date $time [$level] $metadata$message\n",
  metadata: [:user_id]

config :kafka_ex,
  brokers: [{"localhost", 9092}]
