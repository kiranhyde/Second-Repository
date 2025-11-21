export default {
  root: true,
  env: {
    node: true,
    es2022: true,
  },
  parserOptions: {
    project: './tsconfig.json',
    sourceType: 'module',
  },
  extends: ['standard-with-typescript'],
  rules: {
    'max-len': ['error', { code: 100 }],
  },
};
