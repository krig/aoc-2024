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
    if len(numbers) == 0 {
      continue
    }

    if is_safe_part1(numbers) {
      total_safe_part1 += 1
    }

    if is_safe_part2(numbers) {
      total_safe_part2 += 1
    }
  }
  fmt.printf("Total safe (part 1): %i\n", total_safe_part1)
  fmt.printf("Total safe (part 2): %i\n", total_safe_part2)
}

is_safe_part1 :: proc(numbers: []int, skip := -1) -> bool {
  state := 0
  start := 1 if skip == 0 else 0
  last := numbers[start]

  for number, idx in numbers[(start + 1):] {
    if skip == idx + 1 {
      continue
    }
    delta := number - last
    if !slice.contains([]int{1, 2, 3}, abs(delta)) {
      return false
    }

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
  if skip == len(numbers) {
    return false
  }
  if is_safe_part1(numbers, skip) {
    return true
  }
  return is_safe_part2(numbers, skip + 1)
}
