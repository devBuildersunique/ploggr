import { validateEnvironment } from './environment';

describe('environment configuration', () => {
  it('provides local development defaults', () => {
    expect(validateEnvironment({})).toEqual({
      NODE_ENV: 'development',
      HOST: '127.0.0.1',
      PORT: 3000,
    });
  });

  it('accepts environment overrides and converts PORT to a number', () => {
    expect(validateEnvironment({ NODE_ENV: 'production', HOST: '0.0.0.0', PORT: '8080' }))
      .toEqual({ NODE_ENV: 'production', HOST: '0.0.0.0', PORT: 8080 });
  });

  it.each(['', 'abc', '3000.5', '0', '-1', '65536', '3e3'])('rejects invalid PORT=%j', (PORT) => {
    expect(() => validateEnvironment({ PORT })).toThrow('PORT must be an integer');
  });

  it('rejects an unsupported environment', () => {
    expect(() => validateEnvironment({ NODE_ENV: 'unknown' })).toThrow('NODE_ENV must be');
  });

  it('rejects an empty host', () => {
    expect(() => validateEnvironment({ HOST: ' ' })).toThrow('HOST must be');
  });
});
