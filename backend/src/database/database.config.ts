import type { DataSourceOptions } from 'typeorm';
import { validateDatabaseEnvironment, type DatabaseEnvironment } from '../config/environment';
import { loadEnvironmentFile } from '../config/environment-file';
import { VerifyPostgis1794873600000 } from './migrations/1794873600000-VerifyPostgis';

export function loadDatabaseEnvironment(envFile?: string): DatabaseEnvironment {
  loadEnvironmentFile(envFile);
  return validateDatabaseEnvironment(process.env);
}

export function createDatabaseOptions(env: DatabaseEnvironment): DataSourceOptions {
  return {
    type: 'postgres',
    host: env.DB_HOST,
    port: env.DB_PORT,
    database: env.DB_NAME,
    username: env.DB_USER,
    password: env.DB_PASSWORD,
    connectTimeoutMS: 5000,
    extra: { query_timeout: 5000, statement_timeout: 5000 },
    ssl: false,
    synchronize: false,
    migrationsRun: false,
    installExtensions: false,
    entities: [],
    migrations: [VerifyPostgis1794873600000],
    migrationsTableName: 'migrations',
    logging: false,
  };
}
