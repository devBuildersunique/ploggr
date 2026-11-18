export interface DatabaseEnvironment {
  DB_HOST: string;
  DB_PORT: number;
  DB_NAME: string;
  DB_USER: string;
  DB_PASSWORD: string;
}

export interface Environment extends DatabaseEnvironment {
  NODE_ENV: 'development' | 'test' | 'production';
  HOST: string;
  PORT: number;
}

export function validateEnvironment(config: Record<string, unknown>): Environment {
  const nodeEnv = config.NODE_ENV ?? 'development';
  if (nodeEnv !== 'development' && nodeEnv !== 'test' && nodeEnv !== 'production') {
    throw new Error('NODE_ENV must be development, test, or production');
  }

  const host = config.HOST ?? '127.0.0.1';
  if (typeof host !== 'string' || host.trim().length === 0) {
    throw new Error('HOST must be a non-empty hostname or IP address');
  }

  const rawPort = config.PORT ?? '3000';
  const port = Number(rawPort);
  if (!/^\d+$/.test(String(rawPort)) || !Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535');
  }

  return {
    NODE_ENV: nodeEnv,
    HOST: host.trim(),
    PORT: port,
    ...validateDatabaseEnvironment(config),
  };
}

export function validateDatabaseEnvironment(config: Record<string, unknown>): DatabaseEnvironment {
  const rawPort = config.DB_PORT ?? '5432';
  const port = Number(rawPort);
  if (!/^\d+$/.test(String(rawPort)) || !Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('DB_PORT must be an integer between 1 and 65535');
  }

  function text(name: string, fallback?: string): string {
    const value = config[name] ?? fallback;
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new Error(`${name} must be a non-empty string`);
    }
    // Passwords are used verbatim, including intentional surrounding whitespace.
    return name === 'DB_PASSWORD' ? value : value.trim();
  }

  return {
    DB_HOST: text('DB_HOST', '127.0.0.1'),
    DB_PORT: port,
    DB_NAME: text('DB_NAME', 'ploggr'),
    DB_USER: text('DB_USER'),
    DB_PASSWORD: text('DB_PASSWORD'),
  };
}
