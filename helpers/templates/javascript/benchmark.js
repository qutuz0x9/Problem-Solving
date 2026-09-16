/**
 * Lightweight timing benchmark for {{TITLE}}.
 * Run with: node benchmark.js
 */
const { solve } = require("./solution");

const N = 1000;
const start = process.hrtime.bigint();
for (let i = 0; i < N; i++) {
  // TODO: call solve(...) with real arguments
}
const end = process.hrtime.bigint();
console.log(`${N} iterations: ${Number(end - start) / 1e6} ms`);
