import { resolve } from 'node:path';
import { config } from 'dotenv';

/** Shared by ConfigModule and standalone database tools, in src/ and dist/. */
export function environmentFileOptions(): { envFilePath: string; ignoreEnvFile: boolean } {
  return {
    envFilePath: resolve(__dirname, '../../.env'),
    ignoreEnvFile: process.env.NODE_ENV === 'test',
  };
}

export function loadEnvironmentFile(envFile?: string): void {
  const options = environmentFileOptions();
  if (!options.ignoreEnvFile) {
    // Existing process variables win. A missing file is allowed when they supply configuration.
    config({ path: envFile ?? options.envFilePath, quiet: true });
  }
}
