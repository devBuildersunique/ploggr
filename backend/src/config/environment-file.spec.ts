import { Test } from '@nestjs/testing';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { isAbsolute, join, resolve } from 'node:path';
import { validateEnvironment, type DatabaseEnvironment } from './environment';
import { environmentFileOptions } from './environment-file';
import { loadDatabaseEnvironment } from '../database/database.config';

describe('environment file policy shared by NestJS and database tools', () => {
  let directory: string;
  let envFile: string;
  let originalEnv: NodeJS.ProcessEnv;

  beforeEach(() => {
    originalEnv = { ...process.env };
    directory = mkdtempSync(join(tmpdir(), 'ploggr-environment-'));
    envFile = join(directory, '.env');
    writeFileSync(envFile, [
      'HOST=0.0.0.0', 'PORT=3300', 'DB_HOST=database.example', 'DB_PORT=5544',
      'DB_NAME=file_database', 'DB_USER=file_user', 'DB_PASSWORD=" password "',
    ].join('\n'));
    for (const key of ['HOST', 'PORT', 'DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD']) {
      delete process.env[key];
    }
    process.env.NODE_ENV = 'development';
  });

  afterEach(() => {
    jest.restoreAllMocks();
    process.env = originalEnv;
    rmSync(directory, { recursive: true, force: true });
  });

  async function nestConfiguration(): Promise<DatabaseEnvironment> {
    const module = await Test.createTestingModule({
      imports: [ConfigModule.forRoot({
        ...environmentFileOptions(), envFilePath: envFile, validate: validateEnvironment,
      })],
    }).compile();
    try {
      const config = module.get(ConfigService);
      return {
        DB_HOST: config.getOrThrow('DB_HOST'), DB_PORT: config.getOrThrow('DB_PORT'),
        DB_NAME: config.getOrThrow('DB_NAME'), DB_USER: config.getOrThrow('DB_USER'),
        DB_PASSWORD: config.getOrThrow('DB_PASSWORD'),
      };
    } finally {
      await module.close();
    }
  }

  it('resolves an absolute backend .env path even when the caller uses another directory', () => {
    jest.spyOn(process, 'cwd').mockReturnValue(directory);
    const options = environmentFileOptions();
    expect(isAbsolute(options.envFilePath)).toBe(true);
    expect(options.envFilePath).toBe(resolve(__dirname, '../../.env'));
    expect(options.ignoreEnvFile).toBe(false);
  });

  it('gives both entrypoints the same values with process variables taking precedence', async () => {
    process.env.DB_USER = 'process_user';
    process.env.DB_PORT = '6655';
    const beforeLoading = { ...process.env };
    const expected = {
      DB_HOST: 'database.example', DB_PORT: 6655, DB_NAME: 'file_database',
      DB_USER: 'process_user', DB_PASSWORD: ' password ',
    };
    expect(await nestConfiguration()).toEqual(expected);
    process.env = beforeLoading;
    expect(loadDatabaseEnvironment(envFile)).toEqual(expected);
  });

  it('skips local files in test mode for both entrypoints', async () => {
    process.env.NODE_ENV = 'test';
    process.env.DB_USER = 'explicit_test_user';
    process.env.DB_PASSWORD = 'explicit_test_password';
    const beforeLoading = { ...process.env };
    const expected = {
      DB_HOST: '127.0.0.1', DB_PORT: 5432, DB_NAME: 'ploggr',
      DB_USER: 'explicit_test_user', DB_PASSWORD: 'explicit_test_password',
    };
    expect(environmentFileOptions().ignoreEnvFile).toBe(true);
    expect(await nestConfiguration()).toEqual(expected);
    process.env = beforeLoading;
    expect(loadDatabaseEnvironment(envFile)).toEqual(expected);
    expect(process.env.HOST).toBeUndefined();
  });

  it('allows a missing file when credentials are supplied by the process', async () => {
    envFile = join(directory, 'absent.env');
    process.env.DB_USER = 'process_user';
    process.env.DB_PASSWORD = 'process_password';
    expect(await nestConfiguration()).toMatchObject({ DB_USER: 'process_user' });
    expect(loadDatabaseEnvironment(envFile)).toMatchObject({ DB_PASSWORD: 'process_password' });
  });
});
