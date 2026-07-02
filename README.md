# App Max

Projeto Flutter para Windows com backend local em Node.js para automacao web,
scraping e auto clique usando Playwright.

## Estrutura

Flutter em MVP:

- `lib/auth/models`: usuario autenticado, request e resultado de login.
- `lib/auth/views`: login, auth gate e rota protegida.
- `lib/auth/presenters`: fluxo de login.
- `lib/auth/services`: API de auth e sessao JWT persistida.
- `lib/scraper/models`: dados de entrada e saida.
- `lib/scraper/views`: tela e widgets.
- `lib/scraper/presenters`: fluxo entre tela e servicos.
- `lib/scraper/services`: comunicacao com o backend.

Backend modular:

- `backend/src/config`: variaveis de ambiente.
- `backend/src/infrastructure/database`: SQLite/Postgres e migrations simples.
- `backend/src/infrastructure/web-automation`: Playwright, auto clique e
  scraping organizados por classe.
- `backend/src/modules/*/*.model.js`: validacao e modelos do modulo.
- `backend/src/modules/*/*.presenter.js`: formato das respostas HTTP.
- `backend/src/modules/*/*.routes.js`: entrada HTTP.
- `backend/src/modules/*/*.service.js`: regras de uso do modulo.
- `backend/src/modules/*/*.repository.js`: persistencia do modulo.

Automacao web:

- `BrowserSession`: abre e fecha o navegador/pagina.
- `PageActions`: navegar, esperar seletor, clicar e extrair texto.
- `ScrapeWorkflow`: organiza o fluxo completo de scraping com auto clique.
- `FdcLoginWorkflow`: abre o FDC Market, preenche `USUARIO`/`PASS` com
  `fdcUser`/`fdcPass` e envia o login.
- `playwright-automation.service.js`: adaptador usado pelo modulo `scraper`.

Executavel FDC:

- URL: `https://maxxxmoveis.fdcmarketweb.com.br/fdcmarket/index.php`
- Chave: `fdc_login`
- Credenciais: salvas em `Configuracoes` como `FDC usuario` e `FDC senha`.

Niveis de permissao:

- `viewer`: 10
- `operator`: 50
- `admin`: 100

## Requisitos

- Flutter com suporte a Windows habilitado
- Node.js 20 ou superior
- npm

## Backend

```powershell
cd backend
npm install
npm run install:browsers
npm run dev
```

O backend roda em `http://localhost:3333`.

Em desenvolvimento, o backend usa SQLite automaticamente em
`backend/data/app-max.sqlite`. Em producao, defina `NODE_ENV=production` e
`DATABASE_URL` para usar Postgres.

Exemplo dev:

```powershell
cd backend
$env:NODE_ENV="development"
npm run dev
```

Exemplo prod:

```powershell
cd backend
$env:NODE_ENV="production"
$env:DATABASE_URL="postgres://user:password@host:5432/app_max"
$env:DATABASE_SSL="true"
$env:JWT_SECRET="troque-por-um-segredo-forte"
npm start
```

Rotas principais:

- `GET /health`: verifica se o servidor esta ativo.
- `POST /auth/login`: autentica com email e senha e retorna um JWT.
- `GET /auth/me`: retorna o usuario autenticado via `Authorization: Bearer`.
- `GET /auth/me/config`: retorna a configuracao do usuario autenticado.
- `PUT /auth/me/config`: salva `fdcUser`/`fdcPass` do usuario autenticado.
- `POST /auth/users`: cria usuario com `viewer`, `operator` ou `admin`.
  Exige JWT com permissao `admin`.
- `GET /auth/users/:id/config`: retorna a configuracao de um usuario. Exige
  JWT com permissao `admin`.
- `PUT /auth/users/:id/config`: salva `fdcUser`/`fdcPass` de um usuario. Exige
  JWT com permissao `admin`.
- `GET /dashboard`: retorna metricas reais, atividades recentes e executaveis
  registrados para alimentar a dashboard.
- `GET /executables`: lista executaveis registrados.
- `POST /executables`: registra ou atualiza um executavel. Exige permissao
  `admin`.
- `POST /executables/:key/run`: executa e registra uma rotina. Exige permissao
  minima `operator`.
- `POST /scrape`: abre uma URL, opcionalmente espera um seletor, clica em outro
  seletor, extrai texto de um seletor e salva o historico em `scrape_runs`.
  Exige JWT com permissao minima `operator`.

Em desenvolvimento, um admin e criado automaticamente se nao existir:

- email: `admin@appmax.local`
- senha: `admin123456`

Exemplo de login:

```powershell
$body = @{
  email = "admin@appmax.local"
  password = "admin123456"
} | ConvertTo-Json

$login = Invoke-RestMethod `
  -Method Post `
  -Uri "http://localhost:3333/auth/login" `
  -ContentType "application/json" `
  -Body $body

$login.token
```

Exemplo para criar usuario:

```powershell
$headers = @{ Authorization = "Bearer $($login.token)" }
$body = @{
  name = "Operador"
  email = "operador@appmax.local"
  password = "senha123456"
  role = "operator"
} | ConvertTo-Json

Invoke-RestMethod `
  -Method Post `
  -Uri "http://localhost:3333/auth/users" `
  -Headers $headers `
  -ContentType "application/json" `
  -Body $body
```

Exemplo de payload:

```json
{
  "url": "https://example.com",
  "clickSelector": "",
  "waitForSelector": "",
  "extractSelector": "body",
  "headless": false
}
```

## App Windows

Em outro terminal:

```powershell
flutter pub get
flutter run -d windows
```

O app inicia na tela de login. Em desenvolvimento, use:

- backend: `http://localhost:3333`
- email: `admin@appmax.local`
- senha: `admin123456`

Depois do login, o token JWT fica salvo localmente e as rotas protegidas liberam
a tela de automacao. A chamada de scraping envia `Authorization: Bearer <token>`
automaticamente.

## Observacao

Use automacao e scraping apenas em sites onde voce tem permissao para isso e
respeite termos de uso, limites de acesso e dados pessoais.
