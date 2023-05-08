const path = require('path');

module.exports = {
  require: [
    path.join(__dirname, 'node_modules', 'esbuild-register'),
  ],
  extension: ['ts'],
  spec: 'circuits/*/test/*.ts',
  timeout: 10000000
};