import { PageActions } from './page-actions.js';

export class ScrapeWorkflow {
  constructor({ browserSession }) {
    this.browserSession = browserSession;
  }

  async run(command) {
    let currentUrl = command.url;

    try {
      return await this.browserSession.runWithPage(command, async (page) => {
        const actions = new PageActions(page);

        currentUrl = await actions.open(command.url, {
          timeoutMs: command.timeoutMs,
        });

        await actions.waitForVisible(command.waitForSelector);
        await actions.clickFirst(command.clickSelector, {
          timeoutMs: command.timeoutMs,
        });

        return {
          title: await actions.getTitle(),
          finalUrl: actions.currentUrl(),
          text: await actions.extractText(command.extractSelector),
        };
      });
    } catch (error) {
      throw withCurrentUrl(error, currentUrl);
    }
  }
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
