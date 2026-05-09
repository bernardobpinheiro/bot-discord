# MeuBot — Bot do Discord em Elixir

Bot desenvolvido com Elixir e Nostrum para a disciplina de Programação Funcional.

## Comandos

| Comando | Descrição |
|---|---|
| `!ping` | Verifica se o bot está online |
| `!piada` | Retorna uma piada aleatória |
| `!filme <titulo>` | Busca informações de um filme |
| `!pais <nome>` | Busca informações de um país |
| `!conv <valor> <origem> <destino>` | Converte valores entre moedas |
| `!noticias <tema> <quantidade>` | Busca notícias sobre um tema |
| `!lembrar <texto>` | Salva um lembrete |
| `!lembretes` | Lista seus lembretes salvos |
| `!curiosidade <cidade>` | Mostra clima e coordenadas de uma cidade |

## Configuração

### Pré-requisitos
- Elixir 1.14+
- Um bot criado no [Discord Developer Portal](https://discord.com/developers/applications)

### Variáveis de ambiente

Configure as seguintes variáveis de ambiente antes de rodar:

```bash
export DISCORD_TOKEN=seu_token_aqui
export OMDB_KEY=sua_chave_omdb
export GNEWS_KEY=sua_chave_gnews
```

### Instalação

```bash
mix deps.get
iex -S mix
```

## Arquitetura

| Módulo | Responsabilidade |
|---|---|
| `MeuBot.Application` | Ponto de entrada, Supervisor principal |
| `MeuBot.Consumer` | Handler de eventos do Discord, despacho via pattern matching |
| `MeuBot.Commands` | Implementação de cada comando |
| `MeuBot.Store` | Leitura e escrita do arquivo JSON de persistência |

## APIs utilizadas

| API | Comando | Cadastro |
|---|---|---|
| [Official Joke API](https://official-joke-api.appspot.com/) | `!piada` | Não |
| [OMDb API](https://www.omdbapi.com/) | `!filme` | Sim (gratuito) |
| [RestCountries](https://restcountries.com/) | `!pais` | Não |
| [ExchangeRate API](https://open.er-api.com/) | `!conv` | Não |
| [GNews API](https://gnews.io/) | `!noticias` | Sim (gratuito) |
| [Open-Meteo](https://open-meteo.com/) | `!curiosidade` | Não |
| [GeoCoding API](https://geocoding-api.open-meteo.com/) | `!curiosidade` | Não |

## Persistência

O comando `!lembrar` salva dados em `lembretes.json` via `MeuBot.Store` (GenServer).
O arquivo é carregado na inicialização e atualizado a cada escrita.