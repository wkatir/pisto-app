FROM oven/bun:1-alpine AS base
WORKDIR /app

# Instalar dependencias primero (capa cacheada)
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

# Copiar código fuente
COPY src/ ./src/
COPY tsconfig.json ./

# Crear carpeta de uploads (para archivos subidos en producción)
RUN mkdir -p uploads

ENV NODE_ENV=production

EXPOSE 3000

CMD ["bun", "run", "src/index.ts"]
