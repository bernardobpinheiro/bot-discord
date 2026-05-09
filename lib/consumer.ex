  defmodule MeuBot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Consumer
  alias Nostrum.Api.Message

  def start_link(_opts) do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    if msg.author.bot != true do
      processar(msg.content, msg)
    end
  end

  def handle_event(_evento), do: :ok

  # ============================================================
  # Despacho de comandos via Pattern Matching
  # ============================================================

  defp processar("!ping", msg) do
    MeuBot.Commands.ping(msg)
  end

  defp processar("!piada", msg) do
    MeuBot.Commands.piada(msg)
  end

  defp processar("!filme " <> titulo, msg) do
    MeuBot.Commands.filme(msg, titulo)
  end

  defp processar("!pais " <> nome, msg) do
    MeuBot.Commands.pais(msg, nome)
  end

  defp processar("!conv " <> args, msg) do
    case String.split(args, " ") do
      [valor, origem, destino] ->
        MeuBot.Commands.conv(msg, valor, origem, destino)
      _ ->
        Message.create(msg.channel_id, "Uso correto: `!conv <valor> <origem> <destino>`\nEx: `!conv 100 USD BRL`")
    end
  end

  defp processar("!noticias " <> args, msg) do
    case String.split(args, " ", parts: 2) do
      [tema, quantidade] ->
        MeuBot.Commands.noticias(msg, tema, quantidade)
      _ ->
        Message.create(msg.channel_id, "Uso correto: `!noticias <tema> <quantidade>`\nEx: `!noticias tecnologia 3`")
    end
  end

  defp processar("!lembrar " <> texto, msg) do
    MeuBot.Commands.lembrar(msg, texto)
  end

  defp processar("!lembretes", msg) do
    MeuBot.Commands.lembretes(msg)
  end

  defp processar("!curiosidade " <> cidade, msg) do
    MeuBot.Commands.curiosidade(msg, cidade)
  end

  defp processar(_outro, _msg), do: :ok
end
