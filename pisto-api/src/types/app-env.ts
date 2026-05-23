export type AppEnv = {
  Bindings: {
    DATABASE_URL: string;
    JWT_ACCESS_SECRET: string;
    JWT_REFRESH_SECRET: string;
    AI_API_KEY: string;
    AI_BASE_URL: string;
    AI_MODEL: string;
    CORS_ORIGIN: string;
    NODE_ENV: string;
    RATE_LIMIT_ENABLED: string;
    UPLOADS_BUCKET: R2Bucket;
    HYPERDRIVE: Hyperdrive;
  };
  Variables: {
    userId: string;
    businessId: string;
    roles: string[];
  };
};
