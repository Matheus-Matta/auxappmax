import 'dotenv/config';

import { createApp } from './app.js';
import { getEnv } from './config/env.js';
import { createPlaywrightAutomation } from './infrastructure/web-automation/playwright-automation.service.js';
import { createDatabase } from './infrastructure/database/index.js';
import { createAuthMiddleware, requirePermission } from './modules/auth/auth.middleware.js';
import { ROLES } from './modules/auth/auth.model.js';
import { createAuthRepository } from './modules/auth/auth.repository.js';
import { createAuthService } from './modules/auth/auth.service.js';
import { createExecutableRepository } from './modules/executables/executable.repository.js';
import { createExecutableService } from './modules/executables/executable.service.js';
import { createScraperRepository } from './modules/scraper/scraper.repository.js';
import { createScraperService } from './modules/scraper/scraper.service.js';
import { createUserConfigRepository } from './modules/user-config/user-config.repository.js';
import { createUserConfigService } from './modules/user-config/user-config.service.js';

let database;

async function start() {
  const env = getEnv();

  database = createDatabase(env);
  await database.migrate();

  const authRepository = createAuthRepository({ database });
  const authService = createAuthService({
    repository: authRepository,
    authConfig: env.auth,
  });
  await authService.seedAdminUser();

  const authMiddleware = createAuthMiddleware({ authService });
  const requireAdmin = requirePermission(ROLES.admin);
  const requireOperator = requirePermission(ROLES.operator);

  const scraperRepository = createScraperRepository({ database });
  const automation = createPlaywrightAutomation();
  const scraperService = createScraperService({
    automation,
    repository: scraperRepository,
  });
  const executableRepository = createExecutableRepository({ database });
  const executableService = createExecutableService({
    automation,
    repository: executableRepository,
  });
  await executableService.seedDefaultActions();

  const userConfigRepository = createUserConfigRepository({ database });
  const userConfigService = createUserConfigService({
    repository: userConfigRepository,
  });
  const app = createApp({
    authMiddleware,
    authService,
    database,
    executableService,
    requireAdmin,
    requireOperator,
    scraperService,
    userConfigService,
  });

  const server = app.listen(env.port, () => {
    console.log(`Backend App Max rodando em http://localhost:${env.port}`);
    console.log(`Banco de dados ativo: ${database.client}`);
  });

  async function shutdown() {
    server.close(async () => {
      await database.close();
      process.exit(0);
    });
  }

  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

start().catch(async (error) => {
  console.error('Falha ao iniciar backend:', error);
  await database?.close().catch(() => {});
  process.exit(1);
});
