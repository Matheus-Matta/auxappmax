import { Router } from 'express';

import { executableActionSchema } from './executable.model.js';
import {
  presentActionResult,
  presentActions,
  presentDashboard,
  presentValidationFailure,
} from './executable.presenter.js';

export function createExecutableRoutes({
  authMiddleware,
  executableService,
  requireAdmin,
  requireOperator,
}) {
  const router = Router();

  router.get('/dashboard', authMiddleware, async (req, res) => {
    const result = await executableService.getDashboard();
    const response = presentDashboard(result);

    return res.status(response.status).json(response.body);
  });

  router.get('/executables', authMiddleware, async (req, res) => {
    const actions = await executableService.listActions();

    return res.json(presentActions(actions));
  });

  router.post('/executables', authMiddleware, requireAdmin, async (req, res) => {
    return saveAction(req, res, executableService);
  });

  router.patch('/executables/:key', authMiddleware, requireAdmin, async (req, res) => {
    return saveAction(
      {
        ...req,
        body: {
          ...req.body,
          key: req.params.key,
        },
      },
      res,
      executableService,
    );
  });

  router.post(
    '/executables/:key/run',
    authMiddleware,
    requireOperator,
    async (req, res) => {
      const result = await executableService.executeAction(req.params.key, req.user);
      const response = presentActionResult(result);

      return res.status(response.status).json(response.body);
    },
  );

  return router;
}

async function saveAction(req, res, executableService) {
  const parsed = executableActionSchema.safeParse(req.body);

  if (!parsed.success) {
    return res.status(400).json(presentValidationFailure(parsed.error));
  }

  const result = await executableService.saveAction(parsed.data);
  const response = presentActionResult(result);

  return res.status(response.status).json(response.body);
}
