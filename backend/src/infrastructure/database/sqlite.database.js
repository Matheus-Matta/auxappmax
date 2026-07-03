import { mkdirSync } from 'node:fs';
import path from 'node:path';
import { DatabaseSync } from 'node:sqlite';

export function createSqliteDatabase({ sqliteFile }) {
  const filename = path.resolve(process.cwd(), sqliteFile);
  mkdirSync(path.dirname(filename), { recursive: true });

  const db = new DatabaseSync(filename);
  db.exec('PRAGMA foreign_keys = ON;');

  return {
    client: 'sqlite',
    filename,
    async migrate() {
      db.exec(`
        CREATE TABLE IF NOT EXISTS scrape_runs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          url TEXT NOT NULL,
          final_url TEXT,
          title TEXT,
          success INTEGER NOT NULL,
          error TEXT,
          text_excerpt TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          role TEXT NOT NULL,
          permission_level INTEGER NOT NULL,
          active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS user_configs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL UNIQUE,
          fdc_user TEXT NOT NULL DEFAULT '',
          fdc_pass TEXT NOT NULL DEFAULT '',
          automation_framework TEXT NOT NULL DEFAULT 'playwright',
          browser_mode TEXT NOT NULL DEFAULT 'visible',
          browser_engine TEXT NOT NULL DEFAULT 'chromium',
          action_timeout_ms INTEGER NOT NULL DEFAULT 30000,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS executable_actions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action_key TEXT NOT NULL UNIQUE,
          title TEXT NOT NULL,
          subtitle TEXT NOT NULL,
          badge TEXT NOT NULL,
          icon TEXT NOT NULL,
          enabled INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS executable_runs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action_key TEXT NOT NULL,
          title TEXT NOT NULL,
          success INTEGER NOT NULL,
          message TEXT,
          result_json TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        );
      `);
      ensureSqliteColumn(db, 'user_configs', 'automation_framework', "TEXT NOT NULL DEFAULT 'playwright'");
      ensureSqliteColumn(db, 'user_configs', 'browser_mode', "TEXT NOT NULL DEFAULT 'visible'");
      ensureSqliteColumn(db, 'user_configs', 'browser_engine', "TEXT NOT NULL DEFAULT 'chromium'");
      ensureSqliteColumn(db, 'user_configs', 'action_timeout_ms', 'INTEGER NOT NULL DEFAULT 30000');
      ensureSqliteColumn(db, 'executable_runs', 'result_json', 'TEXT');
    },
    async health() {
      db.prepare('SELECT 1 AS ok').get();
      return { ok: true, client: 'sqlite', filename };
    },
    async insertScrapeRun(run) {
      const result = db
        .prepare(`
          INSERT INTO scrape_runs (
            url,
            final_url,
            title,
            success,
            error,
            text_excerpt
          )
          VALUES (?, ?, ?, ?, ?, ?)
        `)
        .run(
          run.url,
          run.finalUrl ?? null,
          run.title ?? null,
          run.success ? 1 : 0,
          run.error ?? null,
          run.textExcerpt ?? null,
        );

      return { id: Number(result.lastInsertRowid) };
    },
    async findUserByEmail(email) {
      const row = db
        .prepare(
          `
            SELECT
              id,
              name,
              email,
              password_hash AS passwordHash,
              role,
              permission_level AS permissionLevel,
              active,
              created_at AS createdAt,
              updated_at AS updatedAt
            FROM users
            WHERE email = ?
          `,
        )
        .get(email);

      return row ? mapSqliteUser(row) : null;
    },
    async findUserById(id) {
      const row = db
        .prepare(
          `
            SELECT
              id,
              name,
              email,
              password_hash AS passwordHash,
              role,
              permission_level AS permissionLevel,
              active,
              created_at AS createdAt,
              updated_at AS updatedAt
            FROM users
            WHERE id = ?
          `,
        )
        .get(id);

      return row ? mapSqliteUser(row) : null;
    },
    async listUsers(search = '') {
      const like = `%${search.trim()}%`;
      const rows = db
        .prepare(
          `
            SELECT
              id,
              name,
              email,
              password_hash AS passwordHash,
              role,
              permission_level AS permissionLevel,
              active,
              created_at AS createdAt,
              updated_at AS updatedAt
            FROM users
            WHERE ? = '%%' OR name LIKE ? OR email LIKE ? OR role LIKE ?
            ORDER BY name ASC
          `,
        )
        .all(like, like, like, like);

      return rows.map(mapSqliteUser);
    },
    async insertUser(user) {
      const result = db
        .prepare(
          `
            INSERT INTO users (
              name,
              email,
              password_hash,
              role,
              permission_level,
              active
            )
            VALUES (?, ?, ?, ?, ?, ?)
          `,
        )
        .run(
          user.name,
          user.email,
          user.passwordHash,
          user.role,
          user.permissionLevel,
          user.active ? 1 : 0,
        );

      return this.findUserById(Number(result.lastInsertRowid));
    },
    async updateUser(id, user) {
      db.prepare(
        `
          UPDATE users
          SET
            name = ?,
            email = ?,
            password_hash = ?,
            role = ?,
            permission_level = ?,
            active = ?,
            updated_at = CURRENT_TIMESTAMP
          WHERE id = ?
        `,
      ).run(
        user.name,
        user.email,
        user.passwordHash,
        user.role,
        user.permissionLevel,
        user.active ? 1 : 0,
        id,
      );

      return this.findUserById(id);
    },
    async deleteUser(id) {
      db.prepare('DELETE FROM users WHERE id = ?').run(id);
    },
    async listExecutableActions() {
      const rows = db
        .prepare(
          `
            SELECT
              id,
              action_key AS "key",
              title,
              subtitle,
              badge,
              icon,
              enabled,
              created_at AS createdAt,
              updated_at AS updatedAt
            FROM executable_actions
            ORDER BY id ASC
          `,
        )
        .all();

      return rows.map(mapSqliteExecutableAction);
    },
    async findExecutableActionByKey(key) {
      const row = db
        .prepare(
          `
            SELECT
              id,
              action_key AS "key",
              title,
              subtitle,
              badge,
              icon,
              enabled,
              created_at AS createdAt,
              updated_at AS updatedAt
            FROM executable_actions
            WHERE action_key = ?
          `,
        )
        .get(key);

      return row ? mapSqliteExecutableAction(row) : null;
    },
    async upsertExecutableAction(action) {
      db.prepare(
        `
          INSERT INTO executable_actions (
            action_key,
            title,
            subtitle,
            badge,
            icon,
            enabled
          )
          VALUES (?, ?, ?, ?, ?, ?)
          ON CONFLICT(action_key) DO UPDATE SET
            title = excluded.title,
            subtitle = excluded.subtitle,
            badge = excluded.badge,
            icon = excluded.icon,
            enabled = excluded.enabled,
            updated_at = CURRENT_TIMESTAMP
        `,
      ).run(
        action.key,
        action.title,
        action.subtitle,
        action.badge,
        action.icon,
        action.enabled ? 1 : 0,
      );

      return this.findExecutableActionByKey(action.key);
    },
    async replaceExecutableActions(actions) {
      db.exec('BEGIN');

      try {
        db.prepare('DELETE FROM executable_actions').run();

        for (const action of actions) {
          db.prepare(
            `
              INSERT INTO executable_actions (
                action_key,
                title,
                subtitle,
                badge,
                icon,
                enabled
              )
              VALUES (?, ?, ?, ?, ?, ?)
            `,
          ).run(
            action.key,
            action.title,
            action.subtitle,
            action.badge,
            action.icon,
            action.enabled ? 1 : 0,
          );
        }

        db.exec('COMMIT');
      } catch (error) {
        db.exec('ROLLBACK');
        throw error;
      }

      return this.listExecutableActions();
    },
    async insertExecutableRun(run) {
      const result = db
        .prepare(
          `
            INSERT INTO executable_runs (
              action_key,
              title,
              success,
              message,
              result_json
            )
            VALUES (?, ?, ?, ?, ?)
          `,
        )
        .run(
          run.key,
          run.title,
          run.success ? 1 : 0,
          run.message ?? null,
          run.resultJson ?? null,
        );

      return { id: Number(result.lastInsertRowid) };
    },
    async listExecutableRuns({ limit, offset }) {
      const total = db
        .prepare('SELECT COUNT(*) AS total FROM executable_runs')
        .get();
      const rows = db
        .prepare(
          `
            SELECT
              id,
              action_key AS "key",
              title,
              success,
              message,
              result_json AS resultJson,
              created_at AS createdAt,
              strftime('%H:%M', created_at) AS time
            FROM executable_runs
            ORDER BY created_at DESC, id DESC
            LIMIT ? OFFSET ?
          `,
        )
        .all(limit, offset);

      return {
        total: Number(total.total ?? 0),
        runs: rows.map(mapSqliteExecutableRun),
      };
    },
    async getDashboardSnapshot() {
      const executableStats = db
        .prepare(
          `
            SELECT
              COUNT(*) AS total,
              SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) AS success
            FROM executable_runs
            WHERE DATE(created_at) = DATE('now')
          `,
        )
        .get();
      const scrapeStats = db
        .prepare(
          `
            SELECT
              COUNT(*) AS total,
              SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) AS success
            FROM scrape_runs
            WHERE DATE(created_at) = DATE('now')
          `,
        )
        .get();
      const actions = db
        .prepare(
          `
            SELECT
              COUNT(*) AS total,
              SUM(CASE WHEN enabled = 1 THEN 1 ELSE 0 END) AS enabled
            FROM executable_actions
          `,
        )
        .get();
      const users = db
        .prepare(
          `
            SELECT
              COUNT(*) AS total,
              SUM(CASE WHEN active = 1 THEN 1 ELSE 0 END) AS active
            FROM users
          `,
        )
        .get();
      const activities = db
        .prepare(
          `
            SELECT
              strftime('%H:%M', created_at) AS time,
              title,
              CASE WHEN success = 1 THEN 'Sucesso' ELSE 'Erro' END AS status,
              created_at AS createdAt
            FROM executable_runs
            UNION ALL
            SELECT
              strftime('%H:%M', created_at) AS time,
              COALESCE(title, url) AS title,
              CASE WHEN success = 1 THEN 'Sucesso' ELSE 'Erro' END AS status,
              created_at AS createdAt
            FROM scrape_runs
            ORDER BY createdAt DESC
            LIMIT 8
          `,
        )
        .all();

      return buildDashboardSnapshot({
        executableStats,
        scrapeStats,
        actions,
        users,
        activities,
      });
    },
    async findUserConfigByUserId(userId) {
      const row = db
        .prepare(
          `
            SELECT
              id,
              user_id AS userId,
              fdc_user AS fdcUser,
              fdc_pass AS fdcPass,
              automation_framework AS automationFramework,
              browser_mode AS browserMode,
              browser_engine AS browserEngine,
              action_timeout_ms AS actionTimeoutMs,
              created_at AS createdAt,
              updated_at AS updatedAt
            FROM user_configs
            WHERE user_id = ?
          `,
        )
        .get(userId);

      return row ?? null;
    },
    async upsertUserConfig(userId, config) {
      db.prepare(
        `
          INSERT INTO user_configs (
            user_id,
            fdc_user,
            fdc_pass,
            automation_framework,
            browser_mode,
            browser_engine,
            action_timeout_ms
          )
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(user_id) DO UPDATE SET
            fdc_user = excluded.fdc_user,
            fdc_pass = excluded.fdc_pass,
            automation_framework = excluded.automation_framework,
            browser_mode = excluded.browser_mode,
            browser_engine = excluded.browser_engine,
            action_timeout_ms = excluded.action_timeout_ms,
            updated_at = CURRENT_TIMESTAMP
        `,
      ).run(
        userId,
        config.fdcUser,
        config.fdcPass,
        config.automationFramework,
        config.browserMode,
        config.browserEngine,
        config.actionTimeoutMs,
      );

      return this.findUserConfigByUserId(userId);
    },
    async close() {
      db.close();
    },
  };
}

function ensureSqliteColumn(db, tableName, columnName, definition) {
  const columns = db.prepare(`PRAGMA table_info(${tableName})`).all();
  const exists = columns.some((column) => column.name === columnName);

  if (!exists) {
    db.exec(`ALTER TABLE ${tableName} ADD COLUMN ${columnName} ${definition};`);
  }
}

function mapSqliteUser(row) {
  return {
    ...row,
    active: row.active === 1,
  };
}

function mapSqliteExecutableAction(row) {
  return {
    ...row,
    enabled: row.enabled === 1,
  };
}

function mapSqliteExecutableRun(row) {
  return {
    ...row,
    success: row.success === 1,
    result: parseJson(row.resultJson),
  };
}

function parseJson(value) {
  if (!value) return {};

  try {
    return JSON.parse(value);
  } catch {
    return {};
  }
}

function buildDashboardSnapshot({
  executableStats,
  scrapeStats,
  actions,
  users,
  activities,
}) {
  const jobsToday = Number(executableStats.total ?? 0) + Number(scrapeStats.total ?? 0);
  const successes =
    Number(executableStats.success ?? 0) + Number(scrapeStats.success ?? 0);
  const successRate = jobsToday === 0 ? 100 : (successes / jobsToday) * 100;

  return {
    metrics: [
      { label: 'Jobs hoje', value: String(jobsToday), meta: 'execucoes' },
      {
        label: 'Sucesso',
        value: `${successRate.toFixed(1).replace('.', ',')}%`,
        meta: `${successes}/${jobsToday}`,
      },
      {
        label: 'Executaveis',
        value: String(actions.enabled ?? 0),
        meta: `${actions.total ?? 0} registrados`,
      },
      {
        label: 'Usuarios',
        value: String(users.active ?? 0),
        meta: `${users.total ?? 0} total`,
      },
    ],
    activities,
  };
}
