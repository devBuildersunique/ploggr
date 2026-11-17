export default {
  testEnvironment: 'node',
  setupFiles: ['<rootDir>/test/setup-env.cjs'],
  testRegex: '.*\\.(spec|e2e-spec)\\.ts$',
  transform: { '^.+\\.ts$': ['ts-jest', { tsconfig: 'tsconfig.json' }] },
  collectCoverageFrom: ['src/**/*.ts', '!src/main.ts'],
  coverageDirectory: 'coverage',
};
