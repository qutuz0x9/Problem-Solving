/**
 * Timing benchmark for {{TITLE}}.
 * Run with: make bench DIR=problems/<platform>/<slug>   (or: node benchmark.js)
 */
const { solve } = require("./solution");

const SIZES = [10, 1000, 100000]; // input sizes to measure (lower them for slow solutions)
const REPEATS = 7; // timed runs per size; the minimum and the median are reported

// TODO: return the arguments for solve() as an array, for an input of size n
// (ideally worst case), e.g. `return [Array.from({ length: n }, (_, i) => i), n];`.
// If solve() changes its input, build a fresh copy inside measure() for every run.
function makeInput(n) {
  void n;
  return [];
}

function measure(n) {
  const args = makeInput(n);
  solve(...args); // warmup
  const times = [];
  for (let i = 0; i < REPEATS; i++) {
    const start = process.hrtime.bigint();
    solve(...args);
    times.push(Number(process.hrtime.bigint() - start) / 1e6);
  }
  times.sort((a, b) => a - b);
  return [times[0], times[Math.floor(times.length / 2)]];
}

console.log("size".padEnd(12) + "min ms".padStart(12) + "median ms".padStart(14));
for (const n of SIZES) {
  const [fastest, median] = measure(n);
  console.log(
    String(n).padEnd(12) + fastest.toFixed(6).padStart(12) + median.toFixed(6).padStart(14),
  );
}
