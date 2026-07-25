import { Hono } from 'hono'
import { vValidator } from '@hono/valibot-validator'
import * as v from 'valibot'
import { randomUUID } from 'crypto'
import { authGuard } from '../../middleware/auth.middleware'
import type { AppEnv } from '../../types/app-env'

const uploads = new Hono<AppEnv>()

const MAX_SIZE = 5 * 1024 * 1024 // 5 MB
const ALLOWED_MIME: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
}
const FOLDERS = ['products', 'expenses', 'avatars', 'logos', 'misc'] as const

const uploadFormSchema = v.object({
  file: v.pipe(
    v.instance(File, 'Archivo no recibido (campo "file")'),
    v.check((f) => Boolean(ALLOWED_MIME[f.type]), 'Formato no soportado. Usá JPG, PNG o WebP.'),
    v.check((f) => f.size <= MAX_SIZE, 'Archivo demasiado grande. Máximo 5 MB.'),
  ),
  folder: v.optional(v.picklist(FOLDERS), 'misc'),
})

const fileParamSchema = v.object({
  folder: v.picklist(FOLDERS),
  filename: v.pipe(v.string(), v.regex(/^[0-9a-f-]{36}\.(jpg|png|webp)$/i, 'Nombre de archivo inválido')),
})

uploads.post('/image', authGuard, vValidator('form', uploadFormSchema), async (c) => {
  const { file, folder } = c.req.valid('form')
  const businessId = c.get('businessId')

  const ext = ALLOWED_MIME[file.type]!
  const filename = `${randomUUID()}.${ext}`
  // The key includes businessId so a tenant can never read another one's files,
  // even by knowing/guessing the other business's UUID.
  const key = `uploads/${businessId}/${folder}/${filename}`

  await c.env.UPLOADS_BUCKET.put(key, file.stream(), {
    httpMetadata: { contentType: file.type },
  })

  const url = `/uploads/${folder}/${filename}`
  return c.json({ url, filename, size: file.size, mimeType: file.type })
})

// Mounted at '/uploads' (see app.ts) → real public URL: /api/v1/uploads/:folder/:filename.
uploads.get('/:folder/:filename', authGuard, vValidator('param', fileParamSchema), async (c) => {
  const { folder, filename } = c.req.valid('param')
  const businessId = c.get('businessId')
  const key = `uploads/${businessId}/${folder}/${filename}`

  const object = await c.env.UPLOADS_BUCKET.get(key)
  if (!object) return c.json({ error: 'Archivo no encontrado' }, 404)

  return new Response(object.body, {
    headers: {
      'Content-Type': object.httpMetadata?.contentType ?? 'application/octet-stream',
      'Cache-Control': 'public, max-age=31536000',
    },
  })
})

export { uploads }
