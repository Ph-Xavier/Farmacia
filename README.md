# Farmacia

**Nome da temática do aplicativo:** Farmácia

**Nome completo do estudante:** Pedro Henrique Xavier Constancio

**Link da API publicada:** https://farmacia-api.onrender.com

**Descrição resumida da aplicação:** aplicativo Flutter para registrar e listar
vendas de uma farmácia, além de cadastrar clientes. Os dados são persistidos
localmente em SQLite e sincronizados com uma API Node.js/Express conectada ao
PostgreSQL, seguindo a estratégia Offline-first.

## Repositórios e entregáveis

- **Repositório Flutter:** https://github.com/Ph-Xavier/Farmacia
- **Repositório da API:** https://github.com/Ph-Xavier/farmacia-api
- **API publicada:** https://farmacia-api.onrender.com
- **Roteiro dos testes obrigatórios:** [`docs/ROTEIRO_TESTES.md`](docs/ROTEIRO_TESTES.md)
- **Vídeo de demonstração:** inserir o link do vídeo antes da entrega no Teams

## Continuidade do projeto

O projeto evolui o aplicativo de vendas da farmácia desenvolvido no 1º
bimestre. A temática, a entidade principal (**venda**) e as telas de dashboard,
listagem e formulário foram mantidas. A novidade desta etapa é a persistência
local e remota com sincronização.

## Funcionalidades

- Dashboard com acesso a vendas, clientes, teste da API e sincronização.
- Cadastro e listagem de **vendas** (valor e número do cupom).
- Cadastro e listagem de **clientes** (nome e código).
- Persistência local com **SQLite** (`sqflite`).
- Comunicação com **API própria** Node.js/Express.
- Banco remoto **PostgreSQL**.
- Camada `services` para HTTP e camada `repository` para acesso aos dados.
- Estratégias de persistência `local`, `remota` e `offlineFirst`.
- Cadastro mantido localmente como **pendente** quando a API falha.
- Sincronização manual pelo dashboard ou pela tela de teste da API.

## Arquitetura

```
Flutter
   ↓
Camada Repository
   ↓
SQLite local + API remota
                 ↓
             PostgreSQL
```

```
lib/
├── components/            # widgets reutilizáveis (Editor)
├── database/              # acesso ao SQLite (app_database.dart)
├── models/                # VendaFarmacia e Cliente
├── repository/            # repositórios local, remoto e offlineFirst
├── screens/               # dashboard, vendas, clientes
├── services/              # comunicação HTTP com a API
├── testes/                # tela de diagnóstico da API
└── main.dart
```

## API própria

- **Repositório da API:** https://github.com/Ph-Xavier/farmacia-api
- **API publicada:** https://farmacia-api.onrender.com

A API contém apenas as rotas da temática farmácia.

> **Importante — deploy no Render:** crie o Web Service com o nome
> `farmacia-api` apontando para o repositório da API. Se o Render gerar um
> subdomínio diferente de `farmacia-api.onrender.com`, atualize o link acima e o
> `ApiService` (ou use `--dart-define=API_BASE_URL=...`). Depois do deploy,
> acesse `/criar-tabelas` uma vez para criar as tabelas no PostgreSQL. Após
> confirmar que o novo serviço está **Live**, exclua o Web Service antigo.

### Rotas principais

| Método | Rota              | Descrição                        |
| ------ | ----------------- | -------------------------------- |
| GET    | `/teste-banco`    | Testa a conexão com o PostgreSQL |
| GET    | `/criar-tabelas`  | Cria as tabelas (idempotente)    |
| GET    | `/vendas`         | Lista as vendas                  |
| POST   | `/vendas`         | Cadastra uma venda               |
| GET    | `/clientes`       | Lista os clientes                |
| POST   | `/clientes`       | Cadastra um cliente              |
| GET    | `/clientes/:id`   | Busca um cliente por id          |

Exemplo de corpo no `POST /vendas`:

```json
{ "valor": 25.5, "numeroCupom": 1234 }
```

Exemplo de corpo no `POST /clientes`:

```json
{ "nome": "Maria Oliveira", "codigo": 4321 }
```

### PostgreSQL

As tabelas são criadas pela rota `GET /criar-tabelas`:

- `vendas (id, valor, numero_cupom)`
- `clientes (id, nome, codigo)`

No Render, configure a variável `DATABASE_URL` com a connection string do
PostgreSQL e acesse `/criar-tabelas` uma vez após o deploy.

## Persistência Offline-first

O modo padrão está definido em
`lib/repository/configuracao_persistencia.dart` como `offlineFirst`.

### API disponível

1. O usuário cadastra uma venda ou cliente.
2. O repository tenta enviar para a API.
3. Em caso de sucesso, o registro também é salvo no SQLite como
   `sincronizado = 1`.

### API indisponível

1. O envio para a API falha (erro ou timeout de 10 segundos).
2. O registro é salvo no SQLite como `sincronizado = 0`.
3. O usuário continua utilizando o aplicativo normalmente.
4. O dashboard passa a exibir a quantidade de registros pendentes.

### Sincronização manual

1. O usuário toca em **Sincronizar pendentes** no dashboard.
2. O repository busca os registros pendentes no SQLite.
3. Cada registro é enviado para a API.
4. Após o sucesso, o registro local é marcado como `sincronizado = 1`.

## Como executar

```bash
flutter pub get
flutter run
```

A URL da API pode ser alterada sem modificar o código:

```bash
flutter run --dart-define=API_BASE_URL=https://sua-api.onrender.com
```

Isso também permite simular a indisponibilidade da API:

```bash
flutter run --dart-define=API_BASE_URL=https://api-invalida.invalid
```

## Testes

### Teste 1 — API funcionando

1. Execute o aplicativo com a URL correta da API.
2. Cadastre uma venda.
3. Confirme a mensagem de sucesso.
4. Consulte `GET /vendas` ou `/clientes`.
5. Confirme que o registro chegou ao PostgreSQL.

### Teste 2 — API indisponível

1. Execute com `--dart-define=API_BASE_URL=https://api-invalida.invalid`.
2. Cadastre uma venda.
3. Confirme que o aplicativo não perdeu o registro.
4. Volte ao dashboard e confirme o contador de pendentes.
5. Abra a lista de vendas e confirme que o registro aparece localmente.

### Teste 3 — Restaurar a API e sincronizar

1. Execute novamente com a URL correta da API.
2. No dashboard, toque em **Sincronizar pendentes**.
3. Confirme a mensagem de sucesso e o contador zerado.
4. Consulte a API/PostgreSQL e confirme o registro remoto.

Mais detalhes em [`docs/ROTEIRO_TESTES.md`](docs/ROTEIRO_TESTES.md).

## Verificações automáticas

```bash
flutter analyze
flutter test
```
