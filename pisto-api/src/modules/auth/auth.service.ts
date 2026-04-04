import { sign, verify } from 'hono/jwt'
import { eq } from 'drizzle-orm'
import { db } from '../../config/database'
import { appUser, business, role, userRole } from '../../db/schema'
import { env } from '../../config/env'
import { AppError } from '../../shared/errors/app-error'

export async function loginUser(email: string, password: string) {
  const users = await db
    .select()
    .from(appUser)
    .where(eq(appUser.email, email))
    .limit(1)

  const user = users[0]
  if (!user || !user.isActive) {
    throw new AppError(401, 'Credenciales inválidas')
  }

  const isValid = await Bun.password.verify(password, user.passwordHash)
  if (!isValid) {
    throw new AppError(401, 'Credenciales inválidas')
  }

  const roles = await getUserRoles(user.id)
  const tokens = await generateTokens(user.id, user.businessId, roles)

  return {
    ...tokens,
    user: {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      roles,
    },
  }
}

export async function registerUser(data: {
  email: string
  password: string
  firstName: string
  lastName: string
  phone?: string
  businessName: string
}) {
  const existing = await db
    .select({ id: appUser.id })
    .from(appUser)
    .where(eq(appUser.email, data.email))
    .limit(1)

  if (existing.length > 0) {
    throw new AppError(409, 'Email ya registrado')
  }

  const passwordHash = await Bun.password.hash(data.password)

  // Transaction: create business + role + user + assignment
  const result = await db.transaction(async (tx) => {
    const [newBusiness] = await tx
      .insert(business)
      .values({ name: data.businessName })
      .returning()

    const [newRole] = await tx
      .insert(role)
      .values({ businessId: newBusiness!.id, name: 'admin', description: 'Administrador' })
      .returning()

    const [newUser] = await tx
      .insert(appUser)
      .values({
        businessId: newBusiness!.id,
        email: data.email,
        passwordHash,
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
      })
      .returning()

    await tx.insert(userRole).values({ userId: newUser!.id, roleId: newRole!.id })

    return { user: newUser!, business: newBusiness! }
  })

  const tokens = await generateTokens(result.user.id, result.business.id, ['admin'])

  return {
    ...tokens,
    user: {
      id: result.user.id,
      email: result.user.email,
      firstName: result.user.firstName,
      lastName: result.user.lastName,
      roles: ['admin'],
    },
  }
}

export async function refreshTokens(refreshToken: string) {
  try {
    const payload = await verify(refreshToken, env.JWT_REFRESH_SECRET, 'HS256')
    const users = await db
      .select()
      .from(appUser)
      .where(eq(appUser.id, payload.sub as string))
      .limit(1)

    const user = users[0]
    if (!user || !user.isActive) {
      throw new AppError(401, 'Token inválido')
    }

    const roles = await getUserRoles(user.id)
    return generateTokens(user.id, user.businessId, roles)
  } catch {
    throw new AppError(401, 'Token expirado o inválido')
  }
}

async function getUserRoles(userId: string): Promise<string[]> {
  const rows = await db
    .select({ roleName: role.name })
    .from(userRole)
    .innerJoin(role, eq(userRole.roleId, role.id))
    .where(eq(userRole.userId, userId))

  return rows.map((r) => r.roleName)
}

async function generateTokens(userId: string, businessId: string, roles: string[]) {
  const now = Math.floor(Date.now() / 1000)

  const accessToken = await sign(
    { sub: userId, businessId, roles, exp: now + 15 * 60 },
    env.JWT_ACCESS_SECRET,
  )

  const refreshToken = await sign(
    { sub: userId, exp: now + 7 * 24 * 60 * 60 },
    env.JWT_REFRESH_SECRET,
  )

  return { accessToken, refreshToken }
}
