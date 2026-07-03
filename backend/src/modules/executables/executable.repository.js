export function createExecutableRepository({ database }) {
  return {
    getDashboardSnapshot() {
      return database.getDashboardSnapshot();
    },
    listActions() {
      return database.listExecutableActions();
    },
    listRuns(pagination) {
      return database.listExecutableRuns(pagination);
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
    replaceActions(actions) {
      return database.replaceExecutableActions(actions);
    },
    insertRun(run) {
      return database.insertExecutableRun(run);
    },
  };
}
