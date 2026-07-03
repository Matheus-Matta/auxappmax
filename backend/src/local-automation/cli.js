import { createPlaywrightAutomation } from '../infrastructure/web-automation/playwright-automation.service.js';

const automation = createPlaywrightAutomation();

async function main() {
  const [command, payloadArg = 'e30='] = process.argv.slice(2);
  const payload = parsePayload(payloadArg);

  if (command === 'scrape') {
    const result = await automation.scrape({
      url: payload.url,
      clickSelector: payload.clickSelector ?? '',
      extractSelector: payload.extractSelector ?? 'body',
      waitForSelector: payload.waitForSelector ?? '',
      headless: payload.headless === true,
      timeoutMs: Number(payload.timeoutMs ?? 30000),
    });

    return {
      ok: true,
      result,
    };
  }

  if (command === 'fdc-login') {
    const result = await automation.loginFdc({
      fdcUser: payload.fdcUser,
      fdcPass: payload.fdcPass,
      headless: payload.headless === true,
      closeDelayMs: Number(payload.closeDelayMs ?? 0),
      timeoutMs: Number(payload.timeoutMs ?? 30000),
    });

    return {
      ok: true,
      result,
    };
  }

  throw new Error(`Comando local desconhecido: ${command}`);
}

function parsePayload(payloadArg) {
  const json = Buffer.from(payloadArg, 'base64').toString('utf8');
  return JSON.parse(json || '{}');
}

main()
  .then((response) => {
    process.stdout.write(JSON.stringify(response));
  })
  .catch((error) => {
    const message = error instanceof Error ? error.message : String(error);

    process.stdout.write(
      JSON.stringify({
        ok: false,
        error: message,
        currentUrl: error?.currentUrl,
      }),
    );
    process.exitCode = 1;
  });
