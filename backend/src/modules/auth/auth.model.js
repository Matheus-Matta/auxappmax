import { z } from 'zod';

export const ROLES = {
  viewer: 10,
  operator: 50,
  admin: 100,
};

export const loginSchema = z.object({
  email: z.string().email().transform((value) => value.toLowerCase().trim()),
  password: z.string().min(8),
});

export const createUserSchema = z.object({
  name: z.string().trim().min(2),
  email: z.string().email().transform((value) => value.toLowerCase().trim()),
  password: z.string().min(8),
  role: z.enum(['viewer', 'operator', 'admin']).default('viewer'),
  active: z.boolean().optional().default(true),
});

export const updateUserSchema = z.object({
  name: z.string().trim().min(2),
  email: z.string().email().transform((value) => value.toLowerCase().trim()),
  password: z.string().min(8).optional().or(z.literal('')),
  role: z.enum(['viewer', 'operator', 'admin']),
  active: z.boolean(),
});

export function getPermissionLevel(role) {
  return ROLES[role] ?? ROLES.viewer;
}

export function sanitizeUser(user) {
  if (!user) return null;

  return {
    id: Number(user.id),
    name: user.name,
    email: user.email,
    role: user.role,
    permissionLevel: Number(user.permissionLevel),
    active: Boolean(user.active),
    createdAt: user.createdAt,
    updatedAt: user.updatedAt,
  };
}
