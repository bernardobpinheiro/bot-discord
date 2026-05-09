import Config

config :nostrum,
  token: System.get_env("DISCORD_TOKEN"),
  gateway_intents: [
    :guilds,
    :guild_messages,
    :message_content
  ]

config :meu_bot,
  omdb_key: System.get_env("OMDB_KEY"),
  gnews_key: System.get_env("GNEWS_KEY")
