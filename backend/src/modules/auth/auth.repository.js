export function createAuthRepository({ database }) {
  return {
    findUserByEmail(email) {
      return database.findUserByEmail(email);
    },
    findUserById(id) {
      return database.findUserById(id);
    },
    insertUser(user) {
      return database.insertUser(user);
    },
    listUsers(search) {
      return database.listUsers(search);
    },
    updateUser(id, user) {
      return database.updateUser(id, user);
    },
    deleteUser(id) {
      return database.deleteUser(id);
    },
  };
}
