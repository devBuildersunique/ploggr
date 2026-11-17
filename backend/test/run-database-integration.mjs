import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { createServer } from 'node:net';
import { fileURLToPath } from 'node:url';

const cwd = fileURLToPath(new URL('../', import.meta.url));
const project = `ploggr-test-${process.pid}-${Date.now()}`;
const env = {
  ...process.env,
  NODE_ENV: 'test', HOST: '127.0.0.1', PORT: '3000',
  DB_HOST: '127.0.0.1', DB_PORT: '0', DB_NAME: 'ploggr_test',
  DB_USER: 'ploggr_test', DB_PASSWORD: 'isolated_app_test_only',
  POSTGRES_PASSWORD: 'isolated_admin_test_only',
};
const composeArgs = ['compose', '--env-file', '.env.example', '-p', project, '-f', 'compose.yaml'];
let cleanupNeeded = false;

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd, env, encoding: 'utf8', timeout: 180000, ...options,
  });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${command} ${args.join(' ')} failed:\n${result.stderr || result.stdout}`);
  }
  return result.stdout;
}

function compose(args, options) {
  return run('docker', [...composeArgs, ...args], options);
}

async function unusedPort() {
  const server = createServer();
  await new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const { port } = server.address();
  await new Promise((resolve, reject) => server.close(error => error ? reject(error) : resolve()));
  return String(port);
}

try {
  // Fail before touching containers if this session cannot use Docker.
  run('docker', ['info', '--format', '{{.ServerVersion}}']);
  cleanupNeeded = true;
  console.log(`Starting isolated database project ${project}`);
  compose(['up', '-d', '--wait', '--wait-timeout', '90']);
  const address = compose(['port', 'database', '5432']).trim();
  env.DB_PORT = address.slice(address.lastIndexOf(':') + 1);
  assert.match(env.DB_PORT, /^\d+$/);

  console.log('Checking source CLI, migrations, database permissions, spatial queries, and Nest lifecycle');
  run('npm', ['run', 'db:check'], { stdio: 'inherit' });
  run('npm', ['exec', '--', 'jest', '--config', 'jest.database.config.mjs', '--runInBand'], {
    stdio: 'inherit',
  });

  console.log('Checking compiled migration and database commands');
  run('npm', ['run', 'build'], { stdio: 'inherit' });
  run('npm', ['run', 'migration:revert:prod'], { stdio: 'inherit' });
  run('npm', ['run', 'migration:run:prod'], { stdio: 'inherit' });
  run('npm', ['run', 'db:check:prod'], { stdio: 'inherit' });

  console.log('Checking persistence across container recreation');
  compose(['up', '-d', '--force-recreate', '--wait', '--wait-timeout', '90']);
  // Keep the selected host port stable during recreation.
  assert.match(run('npm', ['run', 'migration:show:prod']), /\[X\].*VerifyPostgis/);
  run('npm', ['run', 'db:check:prod'], { stdio: 'inherit' });

  console.log('Checking backend startup failure with invalid credentials and an unavailable database');
  for (const overrides of [
    { DB_PASSWORD: 'incorrect_password' },
    { DB_PORT: await unusedPort() },
  ]) {
    const failed = spawnSync(process.execPath, ['dist/main.js'], {
      cwd, env: { ...env, ...overrides }, encoding: 'utf8', timeout: 30000,
    });
    if (failed.error) throw failed.error;
    assert.equal(failed.status, 1, 'Backend must exit with status 1 when its database is unavailable');
    assert.doesNotMatch(`${failed.stdout}${failed.stderr}`, /API listening/);
    assert.ok(!`${failed.stdout}${failed.stderr}`.includes(env.DB_PASSWORD));
  }
  console.log('Database integration checks passed.');
} catch (error) {
  console.error(error instanceof Error ? error.message : 'Database integration checks failed');
  process.exitCode = 1;
} finally {
  // Only this randomly named test project is removed; development volumes are untouched.
  if (cleanupNeeded) {
    const cleanup = spawnSync('docker', [...composeArgs, 'down', '--volumes', '--remove-orphans'], {
      cwd, env, encoding: 'utf8', timeout: 30000,
    });
    if (cleanup.status !== 0) {
      console.error(`Could not clean up test project ${project}: ${cleanup.stderr}`);
      process.exitCode = 1;
    }
  }
}
