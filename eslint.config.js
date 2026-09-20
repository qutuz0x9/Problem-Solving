// ESLint flat config (ESLint >= 9 ignores the old .eslintrc.json format).
// Problems use CommonJS (`require` / `module.exports`) for JavaScript and
// TypeScript compiled to commonjs, and jest globals in the test files.
const js = require("@eslint/js");
const globals = require("globals");
const { defineConfig, globalIgnores } = require("eslint/config");
const tseslint = require("typescript-eslint");

module.exports = defineConfig([
  globalIgnores(["node_modules/", "**/dist/"]),
  js.configs.recommended,
  {
    files: ["**/*.js"],
    languageOptions: {
      sourceType: "commonjs",
      globals: { ...globals.node, ...globals.jest },
    },
  },
  {
    files: ["**/*.ts"],
    extends: [tseslint.configs.recommended],
    languageOptions: {
      globals: { ...globals.node, ...globals.jest },
    },
  },
]);
