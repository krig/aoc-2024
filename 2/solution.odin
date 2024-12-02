package main

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
  input := #load("input.txt", string)

  total_safe := 0

  lines := strings.split_lines(input)
  for line in lines {
    fields := strings.fields(line)
    if len(fields) == 0 {
      continue
    }

    numbers: [dynamic]int
    for field in fields {
      append(&numbers, strconv.atoi(field))
    }

    if is_safe(numbers[:]) {
      total_safe += 1
    }
  }
  fmt.printf("Total safe: %i\n", total_safe)
}

is_safe :: proc(numbers: []int) -> bool {
  state := 0
  last := numbers[0]
  for number in numbers[1:] {
    delta := abs(number - last)
    if delta != 1 && delta != 2 && delta != 3 {
      return false
    }

    if state == 0 {
      state = number > last ? 1 : -1
    } else if state < 0 {
      if number > last {
        return false
      }
    } else if state > 0 {
      if number < last {
        return false
      }
    }
    last = number
  }
  return true
}
