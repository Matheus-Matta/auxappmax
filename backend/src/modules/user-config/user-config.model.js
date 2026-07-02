import { z } from 'zod';

export const updateUserConfigSchema = z.object({
  fdcUser: z.string().trim().max(255).optional().default(''),
  fdcPass: z.string().max(255).optional().default(''),
});

export function normalizeUserConfigBody(body) {
  return {
    fdcUser: body.fdcUser ?? body.fdc_user,
    fdcPass: body.fdcPass ?? body.fdc_pass,
  };
}

export function createEmptyUserConfig(userId) {
  return {
    id: null,
    userId: Number(userId),
    fdcUser: '',
    fdcPass: '',
    createdAt: null,
    updatedAt: null,
  };
}

export function sanitizeUserConfig(config) {
  if (!config) return null;

  return {
    id: config.id === null ? null : Number(config.id),
    userId: Number(config.userId),
    fdcUser: config.fdcUser ?? '',
    fdcPass: config.fdcPass ?? '',
    createdAt: config.createdAt,
    updatedAt: config.updatedAt,
  };
}
