import 'reflect-metadata';
import { DataSource } from 'typeorm';
import { createDatabaseOptions, loadDatabaseEnvironment } from './database.config';
import { checkDatabase } from './database-check';

async function main(): Promise<void> {
  const source = new DataSource(createDatabaseOptions(loadDatabaseEnvironment()));
  try {
    await source.initialize();
    console.log(JSON.stringify(await checkDatabase(source), null, 2));
  } finally {
    if (source.isInitialized) await source.destroy();
  }
}

main().catch(() => {
  // Do not print connection options, credentials, or driver internals.
  console.error('Database check failed. Check DB_* configuration, database health, and PostGIS provisioning.');
  process.exitCode = 1;
});
