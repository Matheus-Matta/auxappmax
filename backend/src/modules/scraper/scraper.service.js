import {
  buildFailedScrapeRun,
  buildSuccessfulScrapeRun,
} from './scraper.model.js';

export function createScraperService({ automation, repository }) {
  return {
    async run(command) {
      try {
        const result = await automation.scrape(command);
        const scrapeRun = await saveScrapeRun(
          repository,
          buildSuccessfulScrapeRun(command, result),
        );

        return {
          ok: true,
          ...result,
          scrapeRun,
        };
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        const scrapeRun = await saveScrapeRun(
          repository,
          buildFailedScrapeRun(command, error),
        );

        return {
          ok: false,
          error: message,
          scrapeRun,
        };
      }
    },
  };
}

async function saveScrapeRun(repository, run) {
  try {
    return await repository.insertRun(run);
  } catch (error) {
    return {
      id: null,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}
