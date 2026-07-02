export function createUserConfigRepository({ database }) {
  return {
    findUserById(id) {
      return database.findUserById(id);
    },
    findUserConfigByUserId(userId) {
      return database.findUserConfigByUserId(userId);
    },
    upsertUserConfig(userId, config) {
      return database.upsertUserConfig(userId, config);
    },
  };
}
