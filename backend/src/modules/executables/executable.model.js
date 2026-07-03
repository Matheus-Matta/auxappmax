import { z } from 'zod';

export const defaultExecutableActions = [
  {
    key: 'test_login_scraping',
    title: 'Fazer login teste',
    subtitle: 'Abre o FDC e testa login com auto clique',
    badge: 'FDC',
    icon: 'key',
    enabled: true,
  },
];

export const executableActionSchema = z.object({
  key: z
    .string()
    .trim()
    .min(2)
    .max(80)
    .regex(/^[a-z0-9_]+$/),
  title: z.string().trim().min(2).max(120),
  subtitle: z.string().trim().min(2).max(180),
  badge: z.string().trim().min(2).max(40),
  icon: z.string().trim().min(2).max(40).default('play'),
  enabled: z.boolean().optional().default(true),
});

export const executableRunResultSchema = z.object({
  success: z.boolean(),
  message: z.string().trim().min(1).max(500),
  result: z.record(z.string(), z.unknown()).optional().default({}),
});

export function sanitizeExecutableAction(action) {
  return {
    id: Number(action.id),
    key: action.key,
    title: action.title,
    subtitle: action.subtitle,
    badge: action.badge,
    icon: action.icon,
    enabled: Boolean(action.enabled),
    createdAt: action.createdAt,
    updatedAt: action.updatedAt,
  };
}
