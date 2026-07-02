import { Router } from 'express';

import {
  normalizeUserConfigBody,
  updateUserConfigSchema,
} from './user-config.model.js';
import {
  presentUserConfigResult,
  presentValidationFailure,
} from './user-config.presenter.js';

export function createUserConfigRoutes({
  authMiddleware,
  requireAdmin,
  userConfigService,
}) {
  const router = Router();

  router.get('/auth/me/config', authMiddleware, async (req, res) => {
    const result = await userConfigService.getConfig(req.user.id);
    const response = presentUserConfigResult(result);

    return res.status(response.status).json(response.body);
  });

  router.put('/auth/me/config', authMiddleware, async (req, res) => {
    return saveConfig(req, res, req.user.id, userConfigService);
  });

  router.get(
    '/auth/users/:id/config',
    authMiddleware,
    requireAdmin,
    async (req, res) => {
      const result = await userConfigService.getConfig(req.params.id);
      const response = presentUserConfigResult(result);

      return res.status(response.status).json(response.body);
    },
  );

  router.put(
    '/auth/users/:id/config',
    authMiddleware,
    requireAdmin,
    async (req, res) => saveConfig(req, res, req.params.id, userConfigService),
  );

  return router;
}

async function saveConfig(req, res, userId, userConfigService) {
  const parsed = updateUserConfigSchema.safeParse(
    normalizeUserConfigBody(req.body),
  );

  if (!parsed.success) {
    return res.status(400).json(presentValidationFailure(parsed.error));
  }

  const result = await userConfigService.saveConfig(userId, parsed.data);
  const response = presentUserConfigResult(result);

  return res.status(response.status).json(response.body);
}
