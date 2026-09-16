// Two Sum (leetcode)
// https://leetcode.com/problems/two-sum/
package p_0001_two_sum

// Solve returns the indices of the two numbers in nums that add up to target.
func Solve(nums []int, target int) []int {
	seen := make(map[int]int, len(nums))
	for i, n := range nums {
		if j, ok := seen[target-n]; ok {
			return []int{j, i}
		}
		seen[n] = i
	}
	return nil
}
