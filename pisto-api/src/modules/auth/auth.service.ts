import { sign, verify } from 'hono/jwt'
import { eq, and, isNull } from 'drizzle-orm'
import { createHash } from 'crypto'
import { db } from '../../config/database'
import { appUser, business, role, userRole, refreshToken } from '../../db/schema'
import { env } from '../../config/env'
import { AppError } from '../../shared/errors/app-error'

export async function loginUser(email: string, password: string) {
  const users = await db.select().from(appUser)
    .where(eq(appUser.email, email))

  const user = users[0]
  if (!user || !user.isActive) throw new AppError(401, 'Credenciales inválidas')

  const isValid = await Bun.password.verify(password, user.passwordHash)
  if (!isValid) throw new AppError(401, 'Credenciales inválidas')

  const roles = await getUserRoles(user.id)
  const tokens = await generateTokens(user.id, user.businessId, roles)
  await createRefreshToken(user.id, tokens.refreshToken)

  return {
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: { id: user.id, email: user.email, firstName: user.firstName, lastName: user.lastName, roles },
  }
}

export async function registerUser(data: {
  email: string; password: string; firstName: string
  lastName: string; phone?: string; businessName: string
}) {
  const existing = await db.select({ id: appUser.id }).from(appUser)
    .where(eq(appUser.email, data.email))

  if (existing.length > 0) throw new AppError(409, 'Email ya registrado')

  const passwordHash = await Bun.password.hash(data.password)

  const result = await db.transaction(async (tx) => {
    const [newBusiness] = await tx.insert(business)
      .output()
      .values({ name: data.businessName })

    const [newRole] = await tx.insert(role)
      .output()
      .values({ businessId: newBusiness!.id, name: 'admin', description: 'Administrador' })

    const [newUser] = await tx.insert(appUser)
      .output()
      .values({
        businessId: newBusiness!.id,
        email: data.email,
        passwordHash,
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
      })

    await tx.insert(userRole).values({ userId: newUser!.id, roleId: newRole!.id })

    return { user: newUser!, business: newBusiness! }
  })

  const tokens = await generateTokens(result.user.id, result.business.id, ['admin'])
  await createRefreshToken(result.user.id, tokens.refreshToken)

  return {
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    user: {
      id: result.user.id,
      email: result.user.email,
      firstName: result.user.firstName,
      lastName: result.user.lastName,
      roles: ['admin'],
    },
  }
}

export async function refreshTokens(refreshTokenStr: string) {
  try {
    const payload = await verify(refreshTokenStr, env.JWT_REFRESH_SECRET, 'HS256')

    const tokens = await db.select().from(refreshToken)
      .where(and(
        eq(refreshToken.tokenHash, hashToken(refreshTokenStr)),
        isNull(refreshToken.revokedAt),
      ))

    const storedToken = tokens[0]
    if (!storedToken) throw new AppError(401, 'Token inválido o revocado')
    if (new Date() > storedToken.expiresAt) throw new AppError(401, 'Token expirado')

    const users = await db.select().from(appUser)
      .where(eq(appUser.id, payload.sub as string))

    const user = users[0]
    if (!user || !user.isActive) throw new AppError(401, 'Usuario no válido o inactivo')

    await revokeRefreshToken(refreshTokenStr)
    const roles = await getUserRoles(user.id)
    const newTokens = await generateTokens(user.id, user.businessId, roles)
    await createRefreshToken(user.id, newTokens.refreshToken)

    return { accessToken: newTokens.accessToken, refreshToken: newTokens.refreshToken }
  } catch (e) {
    if (e instanceof AppError) throw e
    throw new AppError(401, 'Token expirado o inválido')
  }
}

export async function logout(refreshTokenStr: string) {
  await revokeRefreshToken(refreshTokenStr)
}

async function getUserRoles(userId: string): Promise<string[]> {
  const rows = await db.select({ roleName: role.name }).from(userRole)
    .innerJoin(role, eq(userRole.roleId, role.id))
    .where(eq(userRole.userId, userId))
  return rows.map((r) => r.roleName)
}

async function generateTokens(userId: string, businessId: string, roles: string[]) {
  const now = Math.floor(Date.now() / 1000)
  const ACCESS_TTL = 15 * 60
  const REFRESH_TTL = 7 * 24 * 3600

  const accessToken = await sign(
    { sub: userId, businessId, roles, exp: now + ACCESS_TTL },
    env.JWT_ACCESS_SECRET,
  )
  const refreshTokenVal = await sign(
    { sub: userId, exp: now + REFRESH_TTL },
    env.JWT_REFRESH_SECRET,
  )

  return { accessToken, refreshToken: refreshTokenVal }
}

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex')
}

async function createRefreshToken(userId: string, token: string) {
  const expiresAt = new Date()
  expiresAt.setDate(expiresAt.getDate() + 7)
  await db.insert(refreshToken).values({ userId, tokenHash: hashToken(token), expiresAt })
}

async function revokeRefreshToken(token: string) {
  await db.update(refreshToken)
    .set({ revokedAt: new Date() })
    .where(eq(refreshToken.tokenHash, hashToken(token)))
}
