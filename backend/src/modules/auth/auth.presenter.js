import { sanitizeUser } from './auth.model.js';

export function presentLogin(result) {
  if (!result.ok) {
    return {
      status: result.status ?? 401,
      body: {
        ok: false,
        error: result.error,
      },
    };
  }

  return {
    status: 200,
    body: {
      ok: true,
      token: result.token,
      user: sanitizeUser(result.user),
    },
  };
}

export function presentCreateUser(result) {
  if (!result.ok) {
    return {
      status: result.status ?? 400,
      body: {
        ok: false,
        error: result.error,
      },
    };
  }

  return {
    status: 201,
    body: {
      ok: true,
      user: sanitizeUser(result.user),
    },
  };
}

export function presentUserResult(result) {
  if (!result.ok) {
    return {
      status: result.status ?? 400,
      body: { ok: false, error: result.error },
    };
  }

  return {
    status: 200,
    body: { ok: true, user: sanitizeUser(result.user) },
  };
}

export function presentUsers(users) {
  return {
    ok: true,
    users: users.map(sanitizeUser),
  };
}

export function presentDeleteUser(result) {
  if (!result.ok) {
    return {
      status: result.status ?? 400,
      body: { ok: false, error: result.error },
    };
  }

  return {
    status: 200,
    body: { ok: true },
  };
}

export function presentMe(user) {
  return {
    ok: true,
    user: sanitizeUser(user),
  };
}

export function presentValidationFailure(error) {
  return {
    ok: false,
    error: 'Payload invalido.',
    details: error.flatten(),
  };
}
