import { sanitizeExecutableAction } from './executable.model.js';

export function presentDashboard(result) {
  if (!result.ok) {
    return {
      status: result.status ?? 400,
      body: {
        ok: false,
        error: result.error,
        run: result.run,
      },
    };
  }

  return {
    status: 200,
    body: {
      ok: true,
      dashboard: {
        metrics: result.dashboard.metrics,
        activities: result.dashboard.activities,
        actions: result.dashboard.actions.map(sanitizeExecutableAction),
      },
    },
  };
}

export function presentActions(actions) {
  return {
    ok: true,
    actions: actions.map(sanitizeExecutableAction),
  };
}

export function presentRuns(result) {
  if (!result.ok) {
    return {
      status: result.status ?? 400,
      body: { ok: false, error: result.error },
    };
  }

  return {
    status: 200,
    body: {
      ok: true,
      runs: result.runs.map((run) => ({
        id: Number(run.id),
        key: run.key,
        title: run.title,
        success: Boolean(run.success),
        message: run.message ?? '',
        result: run.result ?? {},
        time: run.time ?? '--:--',
        createdAt: run.createdAt,
      })),
      pagination: {
        limit: result.limit,
        offset: result.offset,
        total: result.total,
      },
    },
  };
}

export function presentActionResult(result) {
  if (!result.ok) {
    return {
      status: result.status ?? 400,
      body: { ok: false, error: result.error },
    };
  }

  return {
    status: 200,
    body: {
      ok: true,
      action: sanitizeExecutableAction(result.action),
      message: result.message,
      run: result.run,
    },
  };
}

export function presentValidationFailure(error) {
  return {
    ok: false,
    error: 'Payload invalido.',
    details: error.flatten(),
  };
}
