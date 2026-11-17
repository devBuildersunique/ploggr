// Ordinary tests must not depend on a developer's .env or a running database.
process.env.NODE_ENV = 'test';
process.env.DB_USER = 'ploggr_test';
process.env.DB_PASSWORD = 'test_only_password';
