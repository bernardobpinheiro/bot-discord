defmodule MeuBot.Commands do
  alias Nostrum.Api.Message

  @omdb_key Application.compile_env(:meu_bot, :omdb_key)
  @gnews_key Application.compile_env(:meu_bot, :gnews_key)

  # ============================================================
  # !ping — sem parâmetro
  # ============================================================

  def ping(msg) do
    Message.create(msg.channel_id, "Pong! 🏓")
  end

  # ============================================================
  # !piada — sem parâmetro (bônus)
  # ============================================================

  def piada(msg) do
    url = "https://official-joke-api.appspot.com/random_joke"

    case Tesla.get(url) do
      {:ok, %{status: 200, body: body}} ->
        %{"setup" => setup, "punchline" => punchline} = Jason.decode!(body)
        Message.create(msg.channel_id, "😂 #{setup}\n||#{punchline}||")

      _ ->
        Message.create(msg.channel_id, "Não consegui buscar uma piada agora 😢")
    end
  end

  # ============================================================
  # !filme <titulo> — um parâmetro
  # ============================================================

  def filme(msg, titulo) do
    titulo_formatado = String.replace(titulo, " ", "+")
    url = "https://www.omdbapi.com/?t=#{titulo_formatado}&apikey=#{@omdb_key}"

    case Tesla.get(url) do
      {:ok, %{status: 200, body: body}} ->
        dados = Jason.decode!(body)

        case dados do
          %{"Response" => "True"} ->
            resposta = """
            🎬 **#{dados["Title"]}** (#{dados["Year"]})
            ⭐ Nota: #{dados["imdbRating"]}
            🎭 Gênero: #{dados["Genre"]}
            🎬 Diretor: #{dados["Director"]}
            📝 #{dados["Plot"]}
            """
            Message.create(msg.channel_id, resposta)

          _ ->
            Message.create(msg.channel_id, "Filme não encontrado 🎬")
        end

      _ ->
        Message.create(msg.channel_id, "Erro ao buscar o filme 😢")
    end
  end

  # ============================================================
  # !pais <nome> — um parâmetro
  # ============================================================

  def pais(msg, nome) do
    url = "https://restcountries.com/v3.1/name/#{nome}"

    case Tesla.get(url) do
      {:ok, %{status: 200, body: body}} ->
        [dados | _] = Jason.decode!(body)
        nome_oficial = get_in(dados, ["name", "official"])
        capital = dados |> Map.get("capital", ["N/A"]) |> List.first()
        populacao = dados |> Map.get("population") |> Integer.to_string()
        regiao = Map.get(dados, "region", "N/A")

        resposta = """
        🌍 **#{nome_oficial}**
        🏙 Capital: #{capital}
        👥 População: #{populacao}
        🗺 Região: #{regiao}
        """
        Message.create(msg.channel_id, resposta)

      _ ->
        Message.create(msg.channel_id, "País não encontrado 🌍")
    end
  end

  # ============================================================
  # !conv <valor> <origem> <destino> — dois ou mais parâmetros
  # ============================================================

  def conv(msg, valor, origem, destino) do
    url = "https://open.er-api.com/v6/latest/#{String.upcase(origem)}"

    case Tesla.get(url) do
      {:ok, %{status: 200, body: body}} ->
        dados = Jason.decode!(body)
        taxa = get_in(dados, ["rates", String.upcase(destino)])

        case taxa do
          nil ->
            Message.create(msg.channel_id, "Moeda não encontrada 💱")

          _ ->
            {valor_float, _} = Float.parse(valor)
            resultado = Float.round(valor_float * taxa, 2)
            Message.create(msg.channel_id,
              "💱 #{valor} #{String.upcase(origem)} = #{resultado} #{String.upcase(destino)}")
        end

      _ ->
        Message.create(msg.channel_id, "Erro ao buscar conversão 😢")
    end
  end

  # ============================================================
  # !noticias <tema> <quantidade> — dois ou mais parâmetros
  # ============================================================

  def noticias(msg, tema, quantidade) do
    {qtd, _} = Integer.parse(quantidade)
    qtd = min(qtd, 5)
    url = "https://gnews.io/api/v4/search?q=#{tema}&max=#{qtd}&lang=pt&token=#{@gnews_key}"

    case Tesla.get(url) do
      {:ok, %{status: 200, body: body}} ->
        %{"articles" => artigos} = Jason.decode!(body)

        resposta = artigos
          |> Enum.map(fn a -> "📰 **#{a["title"]}**\n#{a["url"]}" end)
          |> Enum.join("\n\n")

        Message.create(msg.channel_id, "🗞 Notícias sobre **#{tema}**:\n\n#{resposta}")

      _ ->
        Message.create(msg.channel_id, "Erro ao buscar notícias 😢")
    end
  end

  # ============================================================
  # !lembrar <texto> — persistência
  # ============================================================

  def lembrar(msg, texto) do
    usuario = Integer.to_string(msg.author.id)
    MeuBot.Store.adicionar(usuario, texto)
    Message.create(msg.channel_id, "Anotado! ✅")
  end

  # ============================================================
  # !lembretes — persistência
  # ============================================================

  def lembretes(msg) do
    usuario = Integer.to_string(msg.author.id)
    lista = MeuBot.Store.listar(usuario)

    case lista do
      [] ->
        Message.create(msg.channel_id, "Você não tem lembretes salvos 📝")

      _ ->
        itens = lista |> Enum.with_index(1) |> Enum.map(fn {item, i} -> "#{i}. #{item}" end) |> Enum.join("\n")
        Message.create(msg.channel_id, "📝 Seus lembretes:\n#{itens}")
    end
  end

  # ============================================================
  # !curiosidade <cidade> — combinando duas APIs
  # ============================================================

  def curiosidade(msg, cidade) do
    geo_url = "https://geocoding-api.open-meteo.com/v1/search?name=#{cidade}&count=1"

    with {:ok, %{status: 200, body: geo_body}} <- Tesla.get(geo_url),
         %{"results" => [local | _]} <- Jason.decode!(geo_body),
         lat = local["latitude"],
         lon = local["longitude"],
         meteo_url = "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&current_weather=true",
         {:ok, %{status: 200, body: meteo_body}} <- Tesla.get(meteo_url),
         %{"current_weather" => clima} <- Jason.decode!(meteo_body) do

      temp = clima["temperature"]
      vento = clima["windspeed"]

      Message.create(msg.channel_id, """
      🌍 **#{String.capitalize(cidade)}**
      📍 Coordenadas: #{lat}, #{lon}
      🌡 Temperatura atual: #{temp}°C
      💨 Vento: #{vento} km/h
      """)
    else
      _ -> Message.create(msg.channel_id, "Não encontrei essa cidade 🌍")
    end
  end
end
