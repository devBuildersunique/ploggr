import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { createServer } from 'node:net';
import { fileURLToPath } from 'node:url';
import { run, runCli } from './commands.mjs';

export const backend = fileURLToPath(new URL('../', import.meta.url));

export async function unusedPort() {
  const server = createServer();
  await new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const { port } = server.address();
  await new Promise((resolve, reject) => server.close(error => error ? reject(error) : resolve()));
  return String(port);
}

export async function runDatabaseIntegration(signal, checkLiveStack) {
  const project = `ploggr-test-${process.pid}-${Date.now()}`;
  const env = {
    ...process.env,
    NODE_ENV: 'test', HOST: '127.0.0.1', PORT: '3000',
    DB_HOST: '127.0.0.1', DB_PORT: '0', DB_NAME: 'ploggr_test',
    DB_USER: 'ploggr_test', DB_PASSWORD: randomBytes(24).toString('hex'),
    POSTGRES_PASSWORD: randomBytes(24).toString('hex'),
  };
  const exec = (cmd, args, options) => run(cmd, args, { cwd: backend, env, signal, ...options });
  const npm = (name, options) => exec('npm', ['run', name], options);
  const composeArgs = ['compose', '--env-file', '.env.example', '-p', project, '-f', 'compose.yaml'];
  const compose = (args, options) => exec('docker', [...composeArgs, ...args], options);
  await exec('docker', ['info', '--format', '{{.ServerVersion}}']);
  console.log(`Starting isolated database project ${project}`);
  try {
    await compose(['up', '-d', '--wait', '--wait-timeout', '90']);
    const address = await compose(['port', 'database', '5432'], { capture: true });
    env.DB_PORT = address.trim().split(':').at(-1);
    assert.match(env.DB_PORT, /^\d+$/);
    await npm('db:check');
    await exec('npm', ['exec', '--', 'jest', '--config', 'jest.database.config.mjs', '--runInBand']);
    await npm('build');
    await npm('migration:revert:prod');
    await npm('migration:run:prod');
    await npm('db:check:prod');

    // Reuse the dynamically selected host port when recreating the container.
    await compose(['up', '-d', '--force-recreate', '--wait', '--wait-timeout', '90']);
    assert.match(await npm('migration:show:prod', { capture: true }), /\[X\].*VerifyPostgis/);
    await npm('db:check:prod');

    for (const overrides of [{ DB_PASSWORD: 'incorrect_password' }, { DB_PORT: await unusedPort() }]) {
      const output = await exec(process.execPath, ['dist/main.js'], {
        env: { ...env, ...overrides }, capture: true, expectedExit: 1, timeout: 30_000,
      });
      assert.doesNotMatch(output, /API listening/);
      assert.ok(!output.includes(env.DB_PASSWORD));
    }
    if (checkLiveStack) await checkLiveStack({ env, compose, signal });
  } finally {
    // Cleanup also runs after a cancellation. The unique -p owns this volume.
    await compose(['down', '--volumes', '--remove-orphans'], { signal: undefined, timeout: 40_000 });
  }
  console.log('Database integration checks passed.');
}

if (import.meta.main) await runCli(signal => runDatabaseIntegration(signal));
