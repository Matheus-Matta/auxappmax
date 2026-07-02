import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

import { getPermissionLevel, sanitizeUser } from './auth.model.js';

export function createAuthService({ repository, authConfig }) {
  return {
    async seedAdminUser() {
      if (!authConfig.seedAdmin) return null;

      const email = authConfig.admin.email.toLowerCase().trim();
      const existing = await repository.findUserByEmail(email);

      if (existing) return existing;

      const passwordHash = await bcrypt.hash(authConfig.admin.password, 12);

      return repository.insertUser({
        name: authConfig.admin.name,
        email,
        passwordHash,
        role: 'admin',
        permissionLevel: getPermissionLevel('admin'),
        active: true,
      });
    },
    async login({ email, password }) {
      const user = await repository.findUserByEmail(email);

      if (!user || !user.active) {
        return { ok: false, error: 'Email ou senha invalidos.' };
      }

      const passwordMatches = await bcrypt.compare(password, user.passwordHash);

      if (!passwordMatches) {
        return { ok: false, error: 'Email ou senha invalidos.' };
      }

      return {
        ok: true,
        token: signToken(user, authConfig),
        user,
      };
    },
    async createUser(input) {
      const email = input.email.toLowerCase().trim();
      const existing = await repository.findUserByEmail(email);

      if (existing) {
        return {
          ok: false,
          status: 409,
          error: 'Email ja cadastrado.',
        };
      }

      const passwordHash = await bcrypt.hash(input.password, 12);
      const user = await repository.insertUser({
        name: input.name,
        email,
        passwordHash,
        role: input.role,
        permissionLevel: getPermissionLevel(input.role),
        active: input.active,
      });

      return {
        ok: true,
        user,
      };
    },
    async listUsers(search = '') {
      return repository.listUsers(search);
    },
    async updateUser(id, input) {
      const current = await repository.findUserById(id);

      if (!current) {
        return { ok: false, status: 404, error: 'Usuario nao encontrado.' };
      }

      const email = input.email.toLowerCase().trim();
      const existing = await repository.findUserByEmail(email);

      if (existing && Number(existing.id) !== Number(id)) {
        return { ok: false, status: 409, error: 'Email ja cadastrado.' };
      }

      const passwordHash = input.password
        ? await bcrypt.hash(input.password, 12)
        : current.passwordHash;

      const user = await repository.updateUser(id, {
        name: input.name,
        email,
        passwordHash,
        role: input.role,
        permissionLevel: getPermissionLevel(input.role),
        active: input.active,
      });

      return { ok: true, user };
    },
    async deleteUser(id, currentUserId) {
      if (Number(id) === Number(currentUserId)) {
        return { ok: false, status: 400, error: 'Voce nao pode excluir seu proprio usuario.' };
      }

      const user = await repository.findUserById(id);

      if (!user) {
        return { ok: false, status: 404, error: 'Usuario nao encontrado.' };
      }

      await repository.deleteUser(id);
      return { ok: true };
    },
    async verifyToken(token) {
      const payload = jwt.verify(token, authConfig.jwtSecret);
      const user = await repository.findUserById(payload.sub);

      if (!user || !user.active) {
        throw new Error('Usuario inativo ou inexistente.');
      }

      return user;
    },
  };
}

function signToken(user, authConfig) {
  const safeUser = sanitizeUser(user);

  return jwt.sign(
    {
      email: safeUser.email,
      role: safeUser.role,
      permissionLevel: safeUser.permissionLevel,
    },
    authConfig.jwtSecret,
    {
      subject: String(safeUser.id),
      expiresIn: authConfig.jwtExpiresIn,
    },
  );
}
