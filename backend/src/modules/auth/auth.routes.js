import { Router } from 'express';

import {
  presentCreateUser,
  presentDeleteUser,
  presentLogin,
  presentMe,
  presentUserResult,
  presentUsers,
  presentValidationFailure,
} from './auth.presenter.js';
import { createUserSchema, loginSchema, updateUserSchema } from './auth.model.js';

export function createAuthRoutes({ authService, authMiddleware, requireAdmin }) {
  const router = Router();

  router.post('/auth/login', async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);

    if (!parsed.success) {
      return res.status(400).json(presentValidationFailure(parsed.error));
    }

    const result = await authService.login(parsed.data);
    const response = presentLogin(result);

    return res.status(response.status).json(response.body);
  });

  router.get('/auth/me', authMiddleware, (req, res) => {
    res.json(presentMe(req.user));
  });

  router.get('/auth/users', authMiddleware, requireAdmin, async (req, res) => {
    const users = await authService.listUsers(String(req.query.search ?? ''));
    res.json(presentUsers(users));
  });

  router.post('/auth/users', authMiddleware, requireAdmin, async (req, res) => {
    const parsed = createUserSchema.safeParse(req.body);

    if (!parsed.success) {
      return res.status(400).json(presentValidationFailure(parsed.error));
    }

    const result = await authService.createUser(parsed.data);
    const response = presentCreateUser(result);

    return res.status(response.status).json(response.body);
  });

  router.patch('/auth/users/:id', authMiddleware, requireAdmin, async (req, res) => {
    const parsed = updateUserSchema.safeParse(req.body);

    if (!parsed.success) {
      return res.status(400).json(presentValidationFailure(parsed.error));
    }

    const result = await authService.updateUser(req.params.id, parsed.data);
    const response = presentUserResult(result);

    return res.status(response.status).json(response.body);
  });

  router.delete('/auth/users/:id', authMiddleware, requireAdmin, async (req, res) => {
    const result = await authService.deleteUser(req.params.id, req.user.id);
    const response = presentDeleteUser(result);

    return res.status(response.status).json(response.body);
  });

  return router;
}
