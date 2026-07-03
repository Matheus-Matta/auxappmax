# App Max

Aplicativo Flutter Windows para automacao local com Playwright.

O app nao depende de backend. Login, configuracoes, execucoes e relatorios sao
locais no cliente Windows.

## Estrutura

- `lib/auth`: autenticacao local validando acesso no FDC.
- `lib/config`: configuracoes locais seguras, incluindo usuario/senha FDC e
  preferencias de auto clique.
- `lib/home`: dashboard, execucoes e relatorios locais.
- `lib/scraper`: tela de scraping e auto clique local.
- `lib/automation`: adaptador Flutter para executar o CLI Node local.
- `local_automation`: CLI Node com Playwright usado pelo app Flutter.

## Dados Locais

- Configuracoes sensiveis: `flutter_secure_storage`.
- Usuarios locais: `shared_preferences`.
- Relatorios de execucao: arquivo `.logs/executions.log` no diretorio de suporte
  do app.

## Automacao FDC

- URL: `https://maxxxmoveis.fdcmarketweb.com.br/fdcmarket/index.php`
- Campo usuario: `input[name="USUARIO"]`
- Campo senha: `input[name="PASS"]`
- Botao entrar: `input[type="submit"][value="Acessar sistema"]`

## Instalar Dependencias

```powershell
cd D:\projetos\appauxmax
flutter pub get
npm install
npm run install:browsers
```

## Rodar App Windows

```powershell
cd D:\projetos\appauxmax
flutter run -d windows
```

Durante o desenvolvimento:

- `r`: hot reload
- `R`: hot restart
- `q`: fechar o app
