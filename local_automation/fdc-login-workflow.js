import { PageActions } from './page-actions.js';

export const FDC_LOGIN_URL =
  'https://maxxxmoveis.fdcmarketweb.com.br/fdcmarket/index.php';

export class FdcLoginWorkflow {
  constructor({ browserSession }) {
    this.browserSession = browserSession;
  }

  async run({
    fdcUser,
    fdcPass,
    headless = false,
    closeDelayMs = 0,
    timeoutMs = 30000,
    url = FDC_LOGIN_URL,
  }) {
    let currentUrl = url;

    try {
      return await this.browserSession.runWithPage(
        { headless, timeoutMs },
        async (page) => {
          const actions = new PageActions(page);

          currentUrl = await actions.open(url, { timeoutMs });
          await actions.waitForVisible('form[name="form1"], form#well');
          await actions.fillFirst(
            'input[name="USUARIO"]',
            fdcUser.toLowerCase(),
          );
          await actions.fillFirst('input[name="PASS"]', fdcPass);
          await actions.clickFirst(
            'input[type="submit"][value="Acessar sistema"]',
            { timeoutMs },
          );
          await page
            .waitForURL(
              (nextUrl) => !nextUrl.href.includes('/fdcmarket/index.php'),
              { timeout: Math.min(timeoutMs, 5000) },
            )
            .catch(() => {});
          await page
            .waitForLoadState('domcontentloaded', {
              timeout: Math.min(timeoutMs, 3000),
            })
            .catch(() => {});

          const finalUrl = actions.currentUrl();
          const text = await actions.extractText('body');

          if (isStillOnLoginPage({ finalUrl, text })) {
            throw new Error('Login FDC nao confirmado. Verifique usuario e senha.');
          }

          if (closeDelayMs > 0) {
            await page.waitForTimeout(closeDelayMs);
          }

          return {
            title: await actions.getTitle(),
            finalUrl,
            text,
          };
        },
      );
    } catch (error) {
      throw withCurrentUrl(error, currentUrl);
    }
  }
}

function isStillOnLoginPage({ finalUrl, text }) {
  const normalizedText = text.toLowerCase();

  return (
    finalUrl.includes('/fdcmarket/index.php') &&
    normalizedText.includes('acesso restrito') &&
    normalizedText.includes('usu')
  );
}

function withCurrentUrl(error, currentUrl) {
  if (error instanceof Error) {
    error.currentUrl = currentUrl;
    return error;
  }

  const wrappedError = new Error(String(error));
  wrappedError.currentUrl = currentUrl;

  return wrappedError;
}
