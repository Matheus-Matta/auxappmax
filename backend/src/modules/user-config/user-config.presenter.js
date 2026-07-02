import { sanitizeUserConfig } from './user-config.model.js';

export function presentUserConfigResult(result) {
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
      config: sanitizeUserConfig(result.config),
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
