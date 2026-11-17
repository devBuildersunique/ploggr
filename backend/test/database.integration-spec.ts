import 'reflect-metadata';
import { Test } from '@nestjs/testing';
import { DataSource } from 'typeorm';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/app.setup';
import { createDatabaseOptions, loadDatabaseEnvironment } from '../src/database/database.config';
import { checkDatabase } from '../src/database/database-check';
import request from 'supertest';

describe('PostgreSQL / PostGIS foundation (isolated Compose database)', () => {
  let source: DataSource;

  beforeAll(async () => {
    source = new DataSource(createDatabaseOptions(loadDatabaseEnvironment()));
    await source.initialize();
  });

  afterAll(async () => {
    if (source?.isInitialized) await source.destroy();
  });

  it('uses an application role without superuser privileges', async () => {
    const [role] = await source.query(
      'SELECT rolsuper, rolcreatedb, rolcreaterole FROM pg_roles WHERE rolname = current_user',
    );
    expect(role).toEqual({ rolsuper: false, rolcreatedb: false, rolcreaterole: false });
  });

  it('checks connectivity, PostGIS, and spatial operations', async () => {
    expect(await checkDatabase(source)).toMatchObject({
      connectivity: true, postgresql: expect.stringContaining('PostgreSQL'),
      postgis: expect.stringContaining('POSTGIS='),
      spatial: { type: 'Point', coordinates: [78.4867, 17.385] },
    });
  });

  it('records the foundation migration exactly once and safely reverts/reapplies it', async () => {
    expect(await source.showMigrations()).toBe(true);
    expect(await source.runMigrations()).toHaveLength(1);
    expect(await source.showMigrations()).toBe(false);
    expect(await source.runMigrations()).toHaveLength(0);
    await source.undoLastMigration();
    expect(await source.showMigrations()).toBe(true);
    expect((await checkDatabase(source)).connectivity).toBe(true);
    expect(await source.runMigrations()).toHaveLength(1);
  });

  it('has no application tables besides migration metadata', async () => {
    // Extension-owned tables (e.g. spatial_ref_sys) are infrastructure, not domain tables.
    const tables = await source.query(`
      SELECT c.relname AS name FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = 'public' AND c.relkind IN ('r', 'p')
        AND NOT EXISTS (
          SELECT 1 FROM pg_depend d WHERE d.classid = 'pg_class'::regclass
            AND d.objid = c.oid AND d.deptype = 'e'
        ) ORDER BY c.relname
    `);
    expect(tables).toEqual([{ name: 'migrations' }]);
  });

  it('starts NestJS against the real database and releases its pool on shutdown', async () => {
    const module = await Test.createTestingModule({ imports: [AppModule] }).compile();
    const app = module.createNestApplication();
    const applicationSource = app.get(DataSource);
    try {
      configureApp(app);
      await app.init();
      expect(applicationSource.isInitialized).toBe(true);
      await request(app.getHttpServer()).get('/api/health').expect(200, { status: 'ok' });
    } finally {
      await app.close();
    }
    expect(applicationSource.isInitialized).toBe(false);
  });

  it('rejects incorrect credentials', async () => {
    const invalid = new DataSource(createDatabaseOptions({
      ...loadDatabaseEnvironment(), DB_PASSWORD: 'incorrect_password',
    }));
    try {
      await expect(invalid.initialize()).rejects.toThrow();
    } finally {
      if (invalid.isInitialized) await invalid.destroy();
    }
  });
});
