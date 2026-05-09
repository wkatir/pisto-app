import * as v from 'valibot'

const passwordSchema = v.pipe(
  v.string(),
  v.minLength(8, 'Mínimo 8 caracteres'),
  v.maxLength(128, 'Máximo 128 caracteres'),
)

const strongPasswordSchema = v.pipe(
  v.string(),
  v.minLength(8, 'Mínimo 8 caracteres'),
  v.maxLength(128, 'Máximo 128 caracteres'),
  v.regex(/[A-Za-z]/, 'Debe contener al menos una letra'),
  v.regex(/[0-9]/, 'Debe contener al menos un número'),
)

const emailSchema = v.pipe(
  v.string(),
  v.trim(),
  v.toLowerCase(),
  v.email('Email inválido'),
)

export const loginSchema = v.object({
  email: emailSchema,
  password: passwordSchema,
})

export const registerSchema = v.object({
  email: emailSchema,
  password: strongPasswordSchema,
  firstName: v.pipe(v.string(), v.trim(), v.minLength(1, 'Nombre requerido')),
  lastName: v.pipe(v.string(), v.trim(), v.minLength(1, 'Apellido requerido')),
  phone: v.optional(v.pipe(v.string(), v.trim())),
  businessName: v.pipe(v.string(), v.trim(), v.minLength(1, 'Nombre de empresa requerido')),
})

export const refreshSchema = v.object({
  refreshToken: v.pipe(v.string(), v.minLength(1, 'Refresh token requerido')),
})

export const forgotPasswordSchema = v.object({
  email: emailSchema,
})

export const updateProfileSchema = v.object({
  firstName: v.optional(v.pipe(v.string(), v.trim(), v.minLength(1, 'Nombre requerido'))),
  lastName: v.optional(v.pipe(v.string(), v.trim(), v.minLength(1, 'Apellido requerido'))),
  phone: v.optional(v.pipe(v.string(), v.trim())),
  email: v.optional(emailSchema),
  avatarUrl: v.optional(v.union([v.literal(''), v.pipe(v.string(), v.trim())])),
})

export const changePasswordSchema = v.object({
  currentPassword: v.pipe(v.string(), v.minLength(1, 'Contraseña actual requerida')),
  newPassword: strongPasswordSchema,
})
