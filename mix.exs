defmodule MeuBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :meu_bot,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MeuBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
  [
    {:nostrum, "~> 0.10"}, #Discord
    {:tesla, "~> 1.9"}, #Requisições HTTP
    {:jason, "~> 1.4"}, # Serialização JSON
    {:hackney, "~> 1.20"} #Adapter HTTP para Tesla
  ]
 end
end
