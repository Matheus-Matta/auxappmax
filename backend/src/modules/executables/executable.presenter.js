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
