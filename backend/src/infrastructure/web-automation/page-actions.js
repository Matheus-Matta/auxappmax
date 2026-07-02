export class PageActions {
  constructor(page) {
    this.page = page;
  }

  async open(url, { timeoutMs }) {
    await this.page.goto(url, {
      waitUntil: 'domcontentloaded',
      timeout: timeoutMs,
    });

    return this.page.url();
  }

  async waitForVisible(selector) {
    if (!selector) return;

    await this.page.waitForSelector(selector, { state: 'visible' });
  }

  async clickFirst(selector, { timeoutMs }) {
    if (!selector) return;

    await this.page.locator(selector).first().click();
    await this.page
      .waitForLoadState('networkidle', { timeout: timeoutMs })
      .catch(() => {});
  }

  async fillFirst(selector, value) {
    await this.page.locator(selector).first().fill(value);
  }

  async extractText(selector = 'body') {
    const locator = this.page.locator(selector || 'body').first();
    await locator.waitFor({ state: 'attached' });

    return locator.innerText();
  }

  async getTitle() {
    return this.page.title();
  }

  currentUrl() {
    return this.page.url();
  }
}
