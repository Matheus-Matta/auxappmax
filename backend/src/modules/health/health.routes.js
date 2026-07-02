import { Router } from 'express';

import { presentHealth, presentHealthFailure } from './health.presenter.js';

export function createHealthRoutes({ database }) {
  const router = Router();

  router.get('/health', async (_req, res) => {
    try {
      const databaseHealth = await database.health();
      res.json(presentHealth(databaseHealth));
    } catch (error) {
      res.status(503).json(presentHealthFailure(error));
    }
  });

  return router;
}
