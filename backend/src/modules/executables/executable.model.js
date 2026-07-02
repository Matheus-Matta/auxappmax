import { z } from 'zod';

export const defaultExecutableActions = [
  {
    key: 'fdc_login',
    title: 'Login FDC',
    subtitle: 'Acessa o FDC Market com suas credenciais',
    badge: 'FDC',
    icon: 'key',
    enabled: true,
  },
  {
    key: 'sync_base',
    title: 'Sincronizar Base',
    subtitle: 'Atualiza registros do ERP',
    badge: 'ROTINA',
    icon: 'storage',
    enabled: true,
  },
  {
    key: 'report',
    title: 'Gerar Relatorio',
    subtitle: 'Exporta relatorio mensal PDF',
    badge: 'RELATORIO',
    icon: 'description',
    enabled: true,
  },
  {
    key: 'upload',
    title: 'Enviar Arquivos',
    subtitle: 'Upload em lote para o servidor',
    badge: 'TRANSFERENCIA',
    icon: 'upload',
    enabled: true,
  },
  {
    key: 'backup',
    title: 'Baixar Backup',
    subtitle: 'Snapshot dos ultimos 7 dias',
    badge: 'BACKUP',
    icon: 'download',
    enabled: true,
  },
  {
    key: 'email',
    title: 'Disparo de E-mails',
    subtitle: 'Notifica clientes pendentes',
    badge: 'COMUNICACAO',
    icon: 'mail',
    enabled: true,
  },
  {
    key: 'queue',
    title: 'Reprocessar Filas',
    subtitle: 'Executa jobs travados',
    badge: 'SISTEMA',
    icon: 'sync',
    enabled: true,
  },
  {
    key: 'console',
    title: 'Console Remoto',
    subtitle: 'Acesso a scripts internos',
    badge: 'AVANCADO',
    icon: 'terminal',
    enabled: true,
  },
  {
    key: 'folders',
    title: 'Sync de Pastas',
    subtitle: 'Espelhar diretorios de rede',
    badge: 'ARQUIVOS',
    icon: 'folder',
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
