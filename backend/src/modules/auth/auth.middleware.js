export function createAuthMiddleware({ authService }) {
  return async function requireAuth(req, res, next) {
    const authorization = req.headers.authorization ?? '';
    const [scheme, token] = authorization.split(' ');

    if (scheme !== 'Bearer' || !token) {
      return res.status(401).json({
        ok: false,
        error: 'Token JWT ausente.',
      });
    }

    try {
      req.user = await authService.verifyToken(token);
      return next();
    } catch {
      return res.status(401).json({
        ok: false,
        error: 'Token JWT invalido ou expirado.',
      });
    }
  };
}

export function requirePermission(minPermissionLevel) {
  return function permissionMiddleware(req, res, next) {
    const permissionLevel = Number(req.user?.permissionLevel ?? 0);

    if (permissionLevel < minPermissionLevel) {
      return res.status(403).json({
        ok: false,
        error: 'Permissao insuficiente.',
      });
    }

    return next();
  };
}
