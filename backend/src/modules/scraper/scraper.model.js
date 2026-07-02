import { z } from 'zod';

export const scrapeSchema = z.object({
  url: z.string().url(),
  clickSelector: z.string().trim().optional().default(''),
  extractSelector: z.string().trim().optional().default('body'),
  waitForSelector: z.string().trim().optional().default(''),
  headless: z.boolean().optional().default(false),
  timeoutMs: z.number().int().min(1000).max(120000).optional().default(30000),
});

export function buildSuccessfulScrapeRun(command, result) {
  return {
    url: command.url,
    finalUrl: result.finalUrl,
    title: result.title,
    success: true,
    textExcerpt: result.text.slice(0, 10000),
  };
}

export function buildFailedScrapeRun(command, error) {
  const message = error instanceof Error ? error.message : String(error);

  return {
    url: command.url,
    finalUrl: error.currentUrl ?? command.url,
    success: false,
    error: message,
  };
}
