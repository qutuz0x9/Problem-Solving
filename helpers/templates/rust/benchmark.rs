//! Timing benchmark for {{TITLE}}.
//! Run with: make bench DIR=problems/<platform>/<slug>

#[allow(dead_code)]
#[path = "solution.rs"]
mod solution;

use std::hint::black_box;
use std::time::Instant;

/// Input sizes to measure (lower them for slow solutions).
const SIZES: [usize; 3] = [10, 1_000, 100_000];
/// Timed runs per size; the minimum and the median are reported.
const REPEATS: usize = 7;

fn main() {
    println!("{:<12}{:>12}{:>14}", "size", "min ms", "median ms");
    for &n in &SIZES {
        // TODO: build the input for size n (ideally worst case) once, here, and pass it to
        // solve(...) below. If solve() changes its input, copy it inside the timed loop.
        let _ = n;
        black_box(solution::solve()); // warmup
        let mut times = Vec::with_capacity(REPEATS);
        for _ in 0..REPEATS {
            let start = Instant::now();
            black_box(solution::solve());
            times.push(start.elapsed().as_secs_f64() * 1000.0);
        }
        times.sort_by(|a, b| a.partial_cmp(b).unwrap());
        println!("{:<12}{:>12.6}{:>14.6}", n, times[0], times[REPEATS / 2]);
    }
}
