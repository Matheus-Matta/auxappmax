import { createEmptyUserConfig } from './user-config.model.js';

export function createUserConfigService({ repository }) {
  return {
    async getConfig(userId) {
      const user = await repository.findUserById(userId);

      if (!user) {
        return { ok: false, status: 404, error: 'Usuario nao encontrado.' };
      }

      const config = await repository.findUserConfigByUserId(userId);

      return {
        ok: true,
        config: config ?? createEmptyUserConfig(userId),
      };
    },
    async saveConfig(userId, input) {
      const user = await repository.findUserById(userId);

      if (!user) {
        return { ok: false, status: 404, error: 'Usuario nao encontrado.' };
      }

      const config = await repository.upsertUserConfig(userId, {
        fdcUser: input.fdcUser,
        fdcPass: input.fdcPass,
      });

      return { ok: true, config };
    },
  };
}
