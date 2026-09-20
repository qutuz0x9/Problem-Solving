//! Timing benchmark for {{TITLE}}.
//! Run with: make bench DIR=problems/<platform>/<slug>

#[allow(dead_code)]
#[path = "solution.rs"]
mod solution;

use std::hint::black_box;
use std::time::Instant;

/// Input sizes to measure, 10x apart so the growth is easy to see (lower them for slow solutions).
const SIZES: [usize; 5] = [10, 100, 1_000, 10_000, 100_000];
/// Timed runs per size; the minimum and the median are reported.
const REPEATS: usize = 7;

fn main() {
    println!(
        "{:<12}{:>12}{:>14}{:>10}",
        "size", "min ms", "median ms", "growth"
    );
    let mut previous = 0.0;
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
        let fastest = times[0];
        // Time versus the previous size.
        let growth = if previous > 0.0 {
            format!("x{:.1}", fastest / previous)
        } else {
            "-".to_string()
        };
        println!(
            "{:<12}{:>12.6}{:>14.6}{:>10}",
            n,
            fastest,
            times[REPEATS / 2],
            growth
        );
        previous = fastest;
    }
}
