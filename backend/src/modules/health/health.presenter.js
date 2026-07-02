export function presentHealth(databaseHealth) {
  return {
    ok: true,
    service: 'app-max-backend',
    database: databaseHealth,
  };
}

export function presentHealthFailure(error) {
  return {
    ok: false,
    service: 'app-max-backend',
    database: {
      ok: false,
      error: error instanceof Error ? error.message : String(error),
    },
  };
}
