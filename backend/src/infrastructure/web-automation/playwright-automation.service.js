import { BrowserSession } from './browser-session.js';
import { FdcLoginWorkflow } from './fdc-login-workflow.js';
import { ScrapeWorkflow } from './scrape-workflow.js';

export function createPlaywrightAutomation() {
  const browserSession = new BrowserSession();
  const scrapeWorkflow = new ScrapeWorkflow({
    browserSession,
  });
  const fdcLoginWorkflow = new FdcLoginWorkflow({
    browserSession,
  });

  return {
    scrape(command) {
      return scrapeWorkflow.run(command);
    },
    loginFdc(command) {
      return fdcLoginWorkflow.run(command);
    },
  };
}
