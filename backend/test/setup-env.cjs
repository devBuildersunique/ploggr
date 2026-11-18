// Jest's ordinary suites own these values. The real database suite bypasses
// this setup and receives its isolated Compose configuration from the runner.
Object.assign(process.env, {
  NODE_ENV: 'test',
  HOST: '127.0.0.1',
  PORT: '3000',
  DB_HOST: '127.0.0.1',
  DB_PORT: '5432',
  DB_NAME: 'ploggr_test',
  DB_USER: 'ploggr_test',
  DB_PASSWORD: 'test_only_password',
});
