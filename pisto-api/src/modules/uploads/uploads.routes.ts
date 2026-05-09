import { Hono } from 'hono'
import { mkdir, writeFile } from 'fs/promises'
import { join } from 'path'
import { randomUUID } from 'crypto'
import { authGuard } from '../../middleware/auth.middleware'
import type { AppEnv } from '../../types/app-env'

const uploads = new Hono<AppEnv>()

const UPLOAD_ROOT = 'uploads'
const MAX_SIZE = 5 * 1024 * 1024 // 5 MB
const ALLOWED_MIME: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
}
const ALLOWED_FOLDERS = new Set(['products', 'expenses', 'avatars', 'logos'])

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
  const dir = join(UPLOAD_ROOT, folder)
  await mkdir(dir, { recursive: true })
  const path = join(dir, filename)

  const buffer = Buffer.from(await file.arrayBuffer())
  await writeFile(path, buffer)

  // URL pública relativa — el frontend la concatena con la base del API.
  const url = `/${UPLOAD_ROOT}/${folder}/${filename}`
  return c.json({ url, filename, size: file.size, mimeType: file.type })
})

export { uploads }
