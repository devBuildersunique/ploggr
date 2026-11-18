import base from './jest.config.mjs';

export default {
  ...base,
  setupFiles: [],
  testRegex: '.*\\.integration-spec\\.ts$',
  testTimeout: 30000,
};
