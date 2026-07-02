export function getEnv() {
  const nodeEnv = process.env.NODE_ENV ?? 'development';
  const dbClient = process.env.DB_CLIENT ?? (nodeEnv === 'production' ? 'postgres' : 'sqlite');
  const jwtSecret = process.env.JWT_SECRET ?? (nodeEnv === 'production' ? '' : 'dev-secret-change-me');

  if (nodeEnv === 'production' && !jwtSecret) {
    throw new Error('JWT_SECRET precisa estar configurado em producao.');
  }

  return {
    nodeEnv,
    isProduction: nodeEnv === 'production',
    port: Number(process.env.PORT ?? 3333),
    auth: {
      jwtSecret,
      jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '8h',
      seedAdmin: process.env.AUTH_SEED_ADMIN
        ? process.env.AUTH_SEED_ADMIN === 'true'
        : nodeEnv !== 'production',
      admin: {
        name: process.env.AUTH_ADMIN_NAME ?? 'Admin App Max',
        email: process.env.AUTH_ADMIN_EMAIL ?? 'admin@appmax.local',
        password: process.env.AUTH_ADMIN_PASSWORD ?? 'admin123456',
      },
    },
    database: {
      client: dbClient,
      sqliteFile: process.env.SQLITE_FILE ?? './data/app-max.sqlite',
      postgresUrl: process.env.DATABASE_URL,
      postgresSsl: process.env.DATABASE_SSL === 'true',
    },
  };
}
