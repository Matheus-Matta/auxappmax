export function createExecutableRepository({ database }) {
  return {
    getDashboardSnapshot() {
      return database.getDashboardSnapshot();
    },
    listActions() {
      return database.listExecutableActions();
    },
    findActionByKey(key) {
      return database.findExecutableActionByKey(key);
    },
    findUserConfigByUserId(userId) {
      return database.findUserConfigByUserId(userId);
    },
    upsertAction(action) {
      return database.upsertExecutableAction(action);
    },
    insertRun(run) {
      return database.insertExecutableRun(run);
    },
  };
}
