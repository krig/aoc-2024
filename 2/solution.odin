package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

main :: proc() {
  lines := strings.split_lines(#load("input.txt", string))
  total_safe_part1 := 0
  total_safe_part2 := 0

  for line in lines {
    numbers := slice.mapper(strings.fields(line), strconv.atoi)
    (len(numbers) > 0) or_continue

    total_safe_part1 += 1 if is_safe_part1(numbers) else 0
    total_safe_part2 += 1 if is_safe_part2(numbers) else 0
  }
  fmt.printf("Total safe (part 1): %i\n", total_safe_part1)
  fmt.printf("Total safe (part 2): %i\n", total_safe_part2)
}

is_safe_part1 :: proc(numbers: []int, skip := -1) -> bool {
  state := 0
  start := 1 if skip == 0 else 0
  last := numbers[start]

  for number, idx in numbers[(start + 1):] {
    (skip != idx + 1) or_continue
    delta := number - last
    slice.contains([]int{1, 2, 3}, abs(delta)) or_return

    if (state < 0 && delta > 0) || (state > 0 && delta < 0) {
      return false
    }

    if state == 0 {
      state = delta
    }

    last = number
  }
  return true
}

is_safe_part2 :: proc(numbers: []int, skip := -1) -> bool {
  (skip < len(numbers)) or_return
  return true if is_safe_part1(numbers, skip) else is_safe_part2(numbers, skip + 1)
}
