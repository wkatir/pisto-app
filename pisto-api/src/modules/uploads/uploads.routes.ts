import { Hono } from 'hono'
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
const ALLOWED_FOLDERS = new Set(['products', 'expenses', 'avatars', 'logos'])

// Upload imagen a Cloudflare R2
uploads.post('/image', authGuard, async (c) => {
  const body = await c.req.parseBody()
  const file = body.file
  const folderRaw = (body.folder as string | undefined) ?? 'misc'

  if (!(file instanceof File)) {
    return c.json({ error: 'Archivo no recibido (campo "file")' }, 400)
  }
  if (!ALLOWED_MIME[file.type]) {
    return c.json({ error: `Formato no soportado. Usá JPG, PNG o WebP.` }, 400)
  }
  if (file.size > MAX_SIZE) {
    return c.json({ error: `Archivo demasiado grande. Máximo 5 MB.` }, 400)
  }

  const folder = ALLOWED_FOLDERS.has(folderRaw) ? folderRaw : 'misc'
  const ext = ALLOWED_MIME[file.type]!
  const filename = `${randomUUID()}.${ext}`
  const key = `uploads/${folder}/${filename}`

  await c.env.UPLOADS_BUCKET.put(key, file.stream(), {
    httpMetadata: { contentType: file.type },
  })

  const url = `/uploads/${folder}/${filename}`
  return c.json({ url, filename, size: file.size, mimeType: file.type })
})

// Servir archivo desde R2
uploads.get('/uploads/:folder/:filename', async (c) => {
  const folder = c.req.param('folder')
  const filename = c.req.param('filename')
  const key = `uploads/${folder}/${filename}`

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
