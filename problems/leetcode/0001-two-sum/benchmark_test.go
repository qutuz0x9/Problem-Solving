package p_0001_two_sum

import "testing"

func BenchmarkSolve(b *testing.B) {
	nums := []int{2, 7, 11, 15}
	for i := 0; i < b.N; i++ {
		Solve(nums, 9)
	}
}
