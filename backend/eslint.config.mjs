import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  { ignores: ['dist/**', 'coverage/**'] },
  {
    files: ['test/**/*.{mjs,cjs}'],
    languageOptions: { globals: { process: 'readonly', console: 'readonly', URL: 'readonly', AbortController: 'readonly' } },
  },
  js.configs.recommended,
  tseslint.configs.recommended,
);
