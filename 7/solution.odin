package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:text/match"
import "core:math"
import "core:math/bits"

main :: proc() {
  lines := strings.split_lines(#load("input.txt", string))
  sum := 0
  for line in lines {
    sum += calc(line)
  }
  fmt.println(sum)
}

Op :: enum { Add, Mul }

calc :: proc(line: string) -> int {
  head, _, tail := strings.partition(line, ": ")
  total := strconv.atoi(head)
  numbers: [dynamic]int
  for s in strings.split_iterator(&tail, " ") {
    append(&numbers, strconv.atoi(s))
  }

  // max 2^12
  bitlen := len(numbers) - 1
  upto := uint(math.pow2_f64(bitlen))
  for n in 0..<upto {
    try_sum := numbers[0]
    for i := 1; i < len(numbers); i += 1 {
      if ((n >> uint(i - 1)) & 1) != 0 {
        try_sum += numbers[i]
      } else {
        try_sum *= numbers[i]
      }
    }
    if try_sum == total {
       return total
    }
  }
  return 0
}
