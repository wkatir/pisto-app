import * as v from 'valibot'

export const loginSchema = v.object({
  email: v.pipe(v.string(), v.email('Email inválido')),
  password: v.pipe(v.string(), v.minLength(6, 'Mínimo 6 caracteres')),
})

export const registerSchema = v.object({
  email: v.pipe(v.string(), v.email('Email inválido')),
  password: v.pipe(v.string(), v.minLength(6, 'Mínimo 6 caracteres')),
  firstName: v.pipe(v.string(), v.minLength(1, 'Nombre requerido')),
  lastName: v.pipe(v.string(), v.minLength(1, 'Apellido requerido')),
  phone: v.optional(v.string()),
  businessName: v.pipe(v.string(), v.minLength(1, 'Nombre de empresa requerido')),
})

export const refreshSchema = v.object({
  refreshToken: v.pipe(v.string(), v.minLength(1, 'Refresh token requerido')),
})
