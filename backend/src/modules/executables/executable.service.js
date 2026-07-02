import { defaultExecutableActions } from './executable.model.js';

export function createExecutableService({ automation, repository }) {
  return {
    async seedDefaultActions() {
      const existing = await repository.listActions();
      const existingKeys = new Set(existing.map((action) => action.key));

      for (const action of defaultExecutableActions.filter(
        (action) => !existingKeys.has(action.key),
      )) {
        await repository.upsertAction(action);
      }

      return repository.listActions();
    },
    async getDashboard() {
      const [snapshot, actions] = await Promise.all([
        repository.getDashboardSnapshot(),
        repository.listActions(),
      ]);

      return {
        ok: true,
        dashboard: {
          ...snapshot,
          actions: actions.filter((action) => action.enabled),
        },
      };
    },
    async listActions() {
      return repository.listActions();
    },
    async saveAction(input) {
      const action = await repository.upsertAction(input);

      return { ok: true, action };
    },
    async executeAction(key, user) {
      const action = await repository.findActionByKey(key);

      if (!action) {
        return { ok: false, status: 404, error: 'Executavel nao encontrado.' };
      }

      if (!action.enabled) {
        return { ok: false, status: 400, error: 'Executavel desativado.' };
      }

      try {
        const result = await executeByKey({
          action,
          automation,
          repository,
          user,
        });
        const run = await repository.insertRun(result.run);

        return {
          ok: true,
          action,
          run,
          message: result.message,
          result: result.data,
        };
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        const run = await repository.insertRun({
          key: action.key,
          title: action.title,
          success: false,
          message,
        });

        return {
          ok: false,
          status: 400,
          error: message,
          action,
          run,
        };
      }
    },
  };
}

async function executeByKey({ action, automation, repository, user }) {
  if (action.key === 'fdc_login') {
    return executeFdcLogin({ action, automation, repository, user });
  }

  await Promise.resolve();
  const message = `${action.title} concluido`;

  return {
    message,
    data: null,
    run: {
      key: action.key,
      title: action.title,
      success: true,
      message,
    },
  };
}

async function executeFdcLogin({ action, automation, repository, user }) {
  const config = await repository.findUserConfigByUserId(user.id);

  if (!config?.fdcUser || !config?.fdcPass) {
    throw new Error('Configure FDC usuario e FDC senha antes de executar.');
  }

  const result = await automation.loginFdc({
    fdcUser: config.fdcUser,
    fdcPass: config.fdcPass,
    headless: false,
    timeoutMs: 30000,
  });
  const message = `${action.title} concluido`;

  return {
    message,
    data: {
      title: result.title,
      finalUrl: result.finalUrl,
    },
    run: {
      key: action.key,
      title: action.title,
      success: true,
      message,
    },
  };
}
