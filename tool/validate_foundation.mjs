import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { access, mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';
import { run, runCli } from '../backend/test/commands.mjs';
import { backend, runDatabaseIntegration, unusedPort } from '../backend/test/run-database-integration.mjs';

const root = fileURLToPath(new URL('../', import.meta.url));
const nativeTest = 'integration_test/connection_check_test.dart';

async function waitUntil(check, description, signal, timeout) {
  const deadline = Date.now() + timeout;
  do {
    signal.throwIfAborted();
    if (await check()) return;
    await delay(100, undefined, { signal });
  } while (Date.now() < deadline);
  throw new Error(`Timed out waiting for ${description}`);
}

function startApi(env) {
  const child = spawn(process.execPath, ['dist/main.js'], {
    cwd: backend, env, stdio: ['ignore', 'pipe', 'inherit'],
  });
  const closed = once(child, 'close');
  let listening = false;
  child.stdout.setEncoding('utf8').on('data', chunk => {
    process.stdout.write(chunk);
    if (chunk.includes('API listening at')) listening = true;
  });
  return {
    async ready(signal) {
      await waitUntil(() => {
        if (child.exitCode !== null || child.signalCode) throw new Error('Nest exited during startup');
        return listening;
      }, 'Nest startup', signal, 30_000);
    },
    async stop() {
      child.kill('SIGTERM');
      const timer = setTimeout(() => child.kill('SIGKILL'), 5000);
      try { await closed; } finally { clearTimeout(timer); }
    },
  };
}

async function checkLiveStack({ env, compose, signal }) {
  env.PORT = await unusedPort();
  const base = `http://127.0.0.1:${env.PORT}/api/`;
  const syncDir = await mkdtemp(join(tmpdir(), 'ploggr-foundation-'));
  const done = new AbortController();
  const lifetime = AbortSignal.any([signal, done.signal]);
  let api;

  async function checkHealth(databaseUp) {
    const get = path => fetch(base + path, { signal: AbortSignal.any([lifetime, AbortSignal.timeout(12_000)]) });
    const health = await get('health');
    assert.equal(health.status, 200);
    assert.deepEqual(await health.json(), { status: 'ok' });
    const ready = await get('health/ready');
    assert.equal(ready.status, databaseUp ? 200 : 503);
    assert.equal(ready.headers.get('cache-control'), 'no-store');
    const body = await ready.json();
    if (databaseUp) {
      assert.deepEqual(body, { status: 'ok', database: 'up', postgis: 'up' });
    } else {
      assert.ok(Number.isFinite(Date.parse(body.timestamp)));
      assert.deepEqual(body, {
        statusCode: 503, error: 'Service Unavailable', message: 'Internal server error',
        path: '/api/health/ready', timestamp: body.timestamp,
      });
    }
  }

  // The test signals only after the UI assertion succeeds. A private temporary
  // directory keeps outage coordination out of the app and its HTTP API.
  async function transition(name, change) {
    await waitUntil(async () => {
      try { await access(join(syncDir, name)); return true; }
      catch (error) { if (error.code !== 'ENOENT') throw error; return false; }
    }, `Flutter to request ${name}`, lifetime, 240_000);
    console.log(`Checking ${name}`);
    await change();
    await writeFile(join(syncDir, name + '.done'), '');
  }

  async function changeServices() {
    await transition('stop-database', async () => {
      await compose(['stop', 'database']);
      await checkHealth(false);
    });
    await transition('restore-database', async () => {
      await compose(['start', '--wait', '--wait-timeout', '90', 'database']);
      await checkHealth(true);
    });
    await transition('stop-api', async () => { await api.stop(); api = undefined; });
    await transition('restore-api', async () => {
      api = startApi(env);
      await api.ready(lifetime);
      await checkHealth(true);
    });
  }

  let tasks = [];
  try {
    api = startApi(env);
    await api.ready(lifetime);
    await checkHealth(true);
    tasks = [
      run('flutter', ['test', '--no-pub', '-d', 'linux', nativeTest,
        `--dart-define=API_BASE_URL=${base}`, `--dart-define=FOUNDATION_SYNC_DIR=${syncDir}`],
      { cwd: root, signal: lifetime, timeout: 600_000 }),
      changeServices(),
    ];
    await Promise.all(tasks);
  } finally {
    done.abort();
    await Promise.allSettled(tasks);
    try { await api?.stop(); } finally { await rm(syncDir, { recursive: true, force: true }); }
  }
}

await runCli(async signal => {
  const flutter = args => run('flutter', args, { cwd: root, signal, timeout: 600_000 });
  const npm = args => run('npm', args, { cwd: backend, signal, timeout: 600_000 });
  await run('docker', ['info', '--format', '{{.ServerVersion}}'], { signal });
  await flutter(['pub', 'get', '--enforce-lockfile']);
  await npm(['ci', '--include=dev']);
  await run('dart', ['format', '--output=none', '--set-exit-if-changed',
    'lib', 'test', 'integration_test', 'test_driver', 'tool'], { cwd: root, signal });
  await flutter(['analyze', '--no-pub']);
  await flutter(['test', '--no-pub', '--reporter=expanded']);
  await flutter(['test', '--no-pub', '--dart-define-from-file=config/development.example.json',
    'test/core/config/app_config_test.dart']);
  await npm(['run', 'check']);
  await flutter(['build', 'linux', '--debug', '--no-pub']);
  await flutter(['test', '--no-pub', '-d', 'linux', nativeTest, '--dart-define=EXPECT_OFFLINE=true']);
  await runDatabaseIntegration(signal, checkLiveStack);
  console.log('Foundation validation passed.');
});
