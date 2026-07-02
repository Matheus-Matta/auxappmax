import pg from 'pg';

const { Pool } = pg;

export function createPostgresDatabase({ postgresUrl, postgresSsl }) {
  if (!postgresUrl) {
    throw new Error('DATABASE_URL precisa estar configurada para usar Postgres.');
  }

  const pool = new Pool({
    connectionString: postgresUrl,
    ssl: postgresSsl ? { rejectUnauthorized: false } : undefined,
  });

  return {
    client: 'postgres',
    async migrate() {
      await pool.query(`
        CREATE TABLE IF NOT EXISTS scrape_runs (
          id BIGSERIAL PRIMARY KEY,
          url TEXT NOT NULL,
          final_url TEXT,
          title TEXT,
          success BOOLEAN NOT NULL,
          error TEXT,
          text_excerpt TEXT,
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS users (
          id BIGSERIAL PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          role TEXT NOT NULL,
          permission_level INTEGER NOT NULL,
          active BOOLEAN NOT NULL DEFAULT TRUE,
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
          updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS user_configs (
          id BIGSERIAL PRIMARY KEY,
          user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
          fdc_user TEXT NOT NULL DEFAULT '',
          fdc_pass TEXT NOT NULL DEFAULT '',
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
          updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS executable_actions (
          id BIGSERIAL PRIMARY KEY,
          action_key TEXT NOT NULL UNIQUE,
          title TEXT NOT NULL,
          subtitle TEXT NOT NULL,
          badge TEXT NOT NULL,
          icon TEXT NOT NULL,
          enabled BOOLEAN NOT NULL DEFAULT TRUE,
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
          updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS executable_runs (
          id BIGSERIAL PRIMARY KEY,
          action_key TEXT NOT NULL,
          title TEXT NOT NULL,
          success BOOLEAN NOT NULL,
          message TEXT,
          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
      `);
    },
    async health() {
      await pool.query('SELECT 1 AS ok');
      return { ok: true, client: 'postgres' };
    },
    async insertScrapeRun(run) {
      const result = await pool.query(
        `
          INSERT INTO scrape_runs (
            url,
            final_url,
            title,
            success,
            error,
            text_excerpt
          )
          VALUES ($1, $2, $3, $4, $5, $6)
          RETURNING id
        `,
        [
          run.url,
          run.finalUrl ?? null,
          run.title ?? null,
          run.success,
          run.error ?? null,
          run.textExcerpt ?? null,
        ],
      );

      return { id: Number(result.rows[0].id) };
    },
    async findUserByEmail(email) {
      const result = await pool.query(
        `
          SELECT
            id,
            name,
            email,
            password_hash AS "passwordHash",
            role,
            permission_level AS "permissionLevel",
            active,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
          FROM users
          WHERE email = $1
        `,
        [email],
      );

      return result.rows[0] ?? null;
    },
    async findUserById(id) {
      const result = await pool.query(
        `
          SELECT
            id,
            name,
            email,
            password_hash AS "passwordHash",
            role,
            permission_level AS "permissionLevel",
            active,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
          FROM users
          WHERE id = $1
        `,
        [id],
      );

      return result.rows[0] ?? null;
    },
    async listUsers(search = '') {
      const result = await pool.query(
        `
          SELECT
            id,
            name,
            email,
            password_hash AS "passwordHash",
            role,
            permission_level AS "permissionLevel",
            active,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
          FROM users
          WHERE $1 = '' OR name ILIKE $2 OR email ILIKE $2 OR role ILIKE $2
          ORDER BY name ASC
        `,
        [search.trim(), `%${search.trim()}%`],
      );

      return result.rows;
    },
    async insertUser(user) {
      const result = await pool.query(
        `
          INSERT INTO users (
            name,
            email,
            password_hash,
            role,
            permission_level,
            active
          )
          VALUES ($1, $2, $3, $4, $5, $6)
          RETURNING
            id,
            name,
            email,
            password_hash AS "passwordHash",
            role,
            permission_level AS "permissionLevel",
            active,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
        `,
        [
          user.name,
          user.email,
          user.passwordHash,
          user.role,
          user.permissionLevel,
          user.active,
        ],
      );

      return result.rows[0];
    },
    async updateUser(id, user) {
      const result = await pool.query(
        `
          UPDATE users
          SET
            name = $1,
            email = $2,
            password_hash = $3,
            role = $4,
            permission_level = $5,
            active = $6,
            updated_at = NOW()
          WHERE id = $7
          RETURNING
            id,
            name,
            email,
            password_hash AS "passwordHash",
            role,
            permission_level AS "permissionLevel",
            active,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
        `,
        [
          user.name,
          user.email,
          user.passwordHash,
          user.role,
          user.permissionLevel,
          user.active,
          id,
        ],
      );

      return result.rows[0] ?? null;
    },
    async deleteUser(id) {
      await pool.query('DELETE FROM users WHERE id = $1', [id]);
    },
    async listExecutableActions() {
      const result = await pool.query(
        `
          SELECT
            id,
            action_key AS "key",
            title,
            subtitle,
            badge,
            icon,
            enabled,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
          FROM executable_actions
          ORDER BY id ASC
        `,
      );

      return result.rows;
    },
    async findExecutableActionByKey(key) {
      const result = await pool.query(
        `
          SELECT
            id,
            action_key AS "key",
            title,
            subtitle,
            badge,
            icon,
            enabled,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
          FROM executable_actions
          WHERE action_key = $1
        `,
        [key],
      );

      return result.rows[0] ?? null;
    },
    async upsertExecutableAction(action) {
      const result = await pool.query(
        `
          INSERT INTO executable_actions (
            action_key,
            title,
            subtitle,
            badge,
            icon,
            enabled
          )
          VALUES ($1, $2, $3, $4, $5, $6)
          ON CONFLICT (action_key) DO UPDATE SET
            title = EXCLUDED.title,
            subtitle = EXCLUDED.subtitle,
            badge = EXCLUDED.badge,
            icon = EXCLUDED.icon,
            enabled = EXCLUDED.enabled,
            updated_at = NOW()
          RETURNING
            id,
            action_key AS "key",
            title,
            subtitle,
            badge,
            icon,
            enabled,
            created_at AS "createdAt",
            updated_at AS "updatedAt"
        `,
        [
          action.key,
          action.title,
          action.subtitle,
          action.badge,
          action.icon,
          action.enabled,
        ],
      );

      return result.rows[0];
    },
    async insertExecutableRun(run) {
      const result = await pool.query(
        `
          INSERT INTO executable_runs (
            action_key,
            title,
            success,
            message
          )
          VALUES ($1, $2, $3, $4)
          RETURNING id
        `,
        [run.key, run.title, run.success, run.message ?? null],
      );

      return { id: Number(result.rows[0].id) };
    },
    async getDashboardSnapshot() {
      const [executableStats, scrapeStats, actions, users, activities] =
        await Promise.all([
          pool.query(
            `
              SELECT
                COUNT(*)::INT AS total,
                COALESCE(SUM(CASE WHEN success THEN 1 ELSE 0 END), 0)::INT AS success
              FROM executable_runs
              WHERE created_at >= CURRENT_DATE
            `,
          ),
          pool.query(
            `
              SELECT
                COUNT(*)::INT AS total,
                COALESCE(SUM(CASE WHEN success THEN 1 ELSE 0 END), 0)::INT AS success
              FROM scrape_runs
              WHERE created_at >= CURRENT_DATE
            `,
          ),
          pool.query(
            `
              SELECT
                COUNT(*)::INT AS total,
                COALESCE(SUM(CASE WHEN enabled THEN 1 ELSE 0 END), 0)::INT AS enabled
              FROM executable_actions
            `,
          ),
          pool.query(
            `
              SELECT
                COUNT(*)::INT AS total,
                COALESCE(SUM(CASE WHEN active THEN 1 ELSE 0 END), 0)::INT AS active
              FROM users
            `,
          ),
          pool.query(
            `
              SELECT
                TO_CHAR(created_at, 'HH24:MI') AS time,
                title,
                CASE WHEN success THEN 'Sucesso' ELSE 'Erro' END AS status,
                created_at AS "createdAt"
              FROM executable_runs
              UNION ALL
              SELECT
                TO_CHAR(created_at, 'HH24:MI') AS time,
                COALESCE(title, url) AS title,
                CASE WHEN success THEN 'Sucesso' ELSE 'Erro' END AS status,
                created_at AS "createdAt"
              FROM scrape_runs
              ORDER BY "createdAt" DESC
              LIMIT 8
            `,
          ),
        ]);

      return buildDashboardSnapshot({
        executableStats: executableStats.rows[0],
        scrapeStats: scrapeStats.rows[0],
        actions: actions.rows[0],
        users: users.rows[0],
        activities: activities.rows,
      });
    },
    async findUserConfigByUserId(userId) {
      const result = await pool.query(
        `
          SELECT
            id,
            user_id AS "userId",
            fdc_user AS "fdcUser",
            fdc_pass AS "fdcPass",
            created_at AS "createdAt",
            updated_at AS "updatedAt"
          FROM user_configs
          WHERE user_id = $1
        `,
        [userId],
      );

      return result.rows[0] ?? null;
    },
    async upsertUserConfig(userId, config) {
      const result = await pool.query(
        `
          INSERT INTO user_configs (user_id, fdc_user, fdc_pass)
          VALUES ($1, $2, $3)
          ON CONFLICT (user_id) DO UPDATE SET
            fdc_user = EXCLUDED.fdc_user,
            fdc_pass = EXCLUDED.fdc_pass,
            updated_at = NOW()
          RETURNING
            id,
            user_id AS "userId",
            fdc_user AS "fdcUser",
            fdc_pass AS "fdcPass",
            created_at AS "createdAt",
            updated_at AS "updatedAt"
        `,
        [userId, config.fdcUser, config.fdcPass],
      );

      return result.rows[0];
    },
    async close() {
      await pool.end();
    },
  };
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
