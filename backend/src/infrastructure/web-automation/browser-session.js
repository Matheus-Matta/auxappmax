import { chromium } from 'playwright';

export class BrowserSession {
  constructor({ browserType = chromium } = {}) {
    this.browserType = browserType;
  }

  async runWithPage({ headless, timeoutMs }, callback) {
    let browser;

    try {
      browser = await this.browserType.launch({ headless });
      const page = await browser.newPage();
      page.setDefaultTimeout(timeoutMs);

      return await callback(page);
    } finally {
      if (browser) {
        await browser.close();
      }
    }
  }
}
