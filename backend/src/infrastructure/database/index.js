import { createPostgresDatabase } from './postgres.database.js';
import { createSqliteDatabase } from './sqlite.database.js';

export function createDatabase({ database }) {
  if (database.client === 'sqlite') {
    return createSqliteDatabase(database);
  }

  if (database.client === 'postgres') {
    return createPostgresDatabase(database);
  }

  throw new Error(`DB_CLIENT invalido: ${database.client}`);
}
