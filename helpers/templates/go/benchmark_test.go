package {{PACKAGE}}

import (
	"fmt"
	"testing"
)

// makeInput builds the input for size n.
// TODO: return a realistic (ideally worst-case) input, e.g. a slice of n ints.
func makeInput(n int) []int {
	return make([]int, n)
}

// BenchmarkSolve runs Solve on inputs of several sizes. Run it with
// `make bench DIR=problems/<platform>/<slug>` (or `go test -bench=. -run='^$'`).
func BenchmarkSolve(b *testing.B) {
	for _, n := range []int{10, 100, 1000, 10000, 100000} {
		in := makeInput(n)
		b.Run(fmt.Sprintf("n=%d", n), func(b *testing.B) {
			_ = in // TODO: pass `in` to Solve(...)
			for i := 0; i < b.N; i++ {
				// TODO: once Solve returns a value, store it in a package-level
				// variable so the compiler cannot delete the call.
				Solve()
			}
		})
	}
}
