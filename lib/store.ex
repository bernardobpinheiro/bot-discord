defmodule MeuBot.Store do
  use GenServer

  @file_path "lembretes.json"

  # ============================================================
  # API Pública — funções que outros módulos vão chamar
  # ============================================================

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def adicionar(usuario, texto) do
    GenServer.call(__MODULE__, {:adicionar, usuario, texto})
  end

  def listar(usuario) do
    GenServer.call(__MODULE__, {:listar, usuario})
  end

  # ============================================================
  # Callbacks do GenServer — implementação interna
  # ============================================================

  @impl true
  def init(_state) do
    estado = carregar_arquivo()
    {:ok, estado}
  end

  @impl true
  def handle_call({:adicionar, usuario, texto}, _from, estado) do
    lembretes_atuais = Map.get(estado, usuario, [])
    novo_estado = Map.put(estado, usuario, lembretes_atuais ++ [texto])
    salvar_arquivo(novo_estado)
    {:reply, :ok, novo_estado}
  end

  @impl true
  def handle_call({:listar, usuario}, _from, estado) do
    lembretes = Map.get(estado, usuario, [])
    {:reply, lembretes, estado}
  end

  # ============================================================
  # Funções privadas — leitura e escrita no JSON
  # ============================================================

  defp carregar_arquivo do
    case File.read(@file_path) do
      {:ok, conteudo} -> Jason.decode!(conteudo)
      {:error, _} -> %{}
    end
  end

  defp salvar_arquivo(estado) do
    File.write!(@file_path, Jason.encode!(estado))
  end
end
