export function createScraperRepository({ database }) {
  return {
    async insertRun(run) {
      return database.insertScrapeRun(run);
    },
  };
}
