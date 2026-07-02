import cors from 'cors';
import express from 'express';

import { createAuthRoutes } from './modules/auth/auth.routes.js';
import { createExecutableRoutes } from './modules/executables/executable.routes.js';
import { createHealthRoutes } from './modules/health/health.routes.js';
import { createScraperRoutes } from './modules/scraper/scraper.routes.js';
import { createUserConfigRoutes } from './modules/user-config/user-config.routes.js';

export function createApp({
  authMiddleware,
  authService,
  database,
  executableService,
  requireAdmin,
  requireOperator,
  scraperService,
  userConfigService,
}) {
  const app = express();

  app.use(cors());
  app.use(express.json({ limit: '1mb' }));
  app.use(createHealthRoutes({ database }));
  app.use(createAuthRoutes({ authService, authMiddleware, requireAdmin }));
  app.use(
    createExecutableRoutes({
      authMiddleware,
      executableService,
      requireAdmin,
      requireOperator,
    }),
  );
  app.use(
    createUserConfigRoutes({
      authMiddleware,
      requireAdmin,
      userConfigService,
    }),
  );
  app.use(createScraperRoutes({ scraperService, authMiddleware, requireOperator }));

  return app;
}
