import { app } from './app'
import { env } from './config/env'

console.log(`🚀 Pisto API running on http://localhost:${env.PORT}`)

export default {
  port: env.PORT,
  fetch: app.fetch,
}
