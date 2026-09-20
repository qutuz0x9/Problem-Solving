/**
 * Timing benchmark for {{TITLE}}.
 * Run with: make bench DIR=problems/<platform>/<slug>   (or: node benchmark.js)
 */
const { solve } = require("./solution");

// Input sizes to measure, 10x apart so the growth is easy to see (lower them for slow solutions).
const SIZES = [10, 100, 1000, 10000, 100000];
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

console.log(
  "size".padEnd(12) + "min ms".padStart(12) + "median ms".padStart(14) + "growth".padStart(10),
);
let previous = 0;
for (const n of SIZES) {
  const [fastest, median] = measure(n);
  const growth = previous > 0 ? `x${(fastest / previous).toFixed(1)}` : "-"; // vs the previous size
  console.log(
    String(n).padEnd(12) +
      fastest.toFixed(6).padStart(12) +
      median.toFixed(6).padStart(14) +
      growth.padStart(10),
  );
  previous = fastest;
}
