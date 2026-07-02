import { Router } from 'express';

import {
  presentScrapeResult,
  presentValidationFailure,
} from './scraper.presenter.js';
import { scrapeSchema } from './scraper.model.js';

export function createScraperRoutes({
  scraperService,
  authMiddleware,
  requireOperator,
}) {
  const router = Router();

  router.post('/scrape', authMiddleware, requireOperator, async (req, res) => {
    const parsed = scrapeSchema.safeParse(req.body);

    if (!parsed.success) {
      return res.status(400).json(presentValidationFailure(parsed.error));
    }

    const result = await scraperService.run(parsed.data);
    const response = presentScrapeResult(result);

    return res.status(response.status).json(response.body);
  });

  return router;
}
