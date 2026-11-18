import { spawn } from 'node:child_process';
import { clearTimeout, setTimeout } from 'node:timers';

// The validation tools run on Linux. Stop the entire npm/Flutter process tree
// before releasing its database or returning control to the caller.
export function run(command, args, {
  cwd, env, signal, capture = false, expectedExit = 0, timeout = 180_000,
} = {}) {
  signal?.throwIfAborted();
  const label = [command, ...args].join(' ');
  console.log(`> ${label}`);
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd, env, detached: true, stdio: capture ? ['ignore', 'pipe', 'pipe'] : 'inherit',
    });
    let output = '';
    let failure;
    let escalation;
    function killGroup(killSignal) {
      if (!child.pid) return;
      try {
        process.kill(-child.pid, killSignal);
      } catch (error) {
        if (error.code !== 'ESRCH') throw error;
      }
    }
    function stop(reason) {
      if (failure) return;
      failure = reason;
      killGroup('SIGTERM');
      escalation = setTimeout(() => killGroup('SIGKILL'), 3000);
    }
    const abort = () => stop(signal.reason);
    signal?.addEventListener('abort', abort, { once: true });
    const timer = setTimeout(() => stop(new Error(`Timed out: ${label}`)), timeout);
    for (const stream of [child.stdout, child.stderr]) {
      stream?.setEncoding('utf8').on('data', chunk => { output += chunk; });
    }
    child.once('error', error => { failure = error; });
    child.once('close', (code, termination) => {
      clearTimeout(timer);
      clearTimeout(escalation);
      signal?.removeEventListener('abort', abort);
      if (failure) reject(failure);
      else if (code === expectedExit) resolve(output);
      else reject(new Error(`${label} exited with ${termination ?? code}\n${output}`));
    });
  });
}

export async function runCli(task) {
  const controller = new AbortController();
  const interrupt = name => controller.abort(new Error(`Interrupted by ${name}`));
  process.on('SIGINT', interrupt);
  process.on('SIGTERM', interrupt);
  try {
    await task(controller.signal);
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  } finally {
    process.off('SIGINT', interrupt);
    process.off('SIGTERM', interrupt);
  }
}
