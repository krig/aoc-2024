package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

main :: proc() {
  lines := strings.split_lines(#load("input.txt", string))
  sum :uint = 0
  numbers: [dynamic]uint
  for line in lines {
    sum += calc(line, &numbers)
    clear(&numbers)
  }
  fmt.println(sum)
}

calc :: proc(line: string, numbers: ^[dynamic]uint) -> uint {
  using strings
  using strconv

  head, _, tail := partition(line, ": ")
  total := uint(atoi(head))
  for s in split_iterator(&tail, " ") {
    append(numbers, uint(atoi(s)))
  }

  if len(numbers^) == 0 do return 0
  sum := calc_sum(numbers^, total)
  if sum == total do return sum
  return calc_sum_2(numbers^, total)
}

calc_sum :: proc(numbers: [dynamic]uint, total: uint) -> uint {
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

// thx Laytan via p1xelHerO
concat :: proc(a, b: uint) -> uint {
  c : uint = 10
  for c < b do c *= 10
  return a*c + b
}

calc_rec :: proc(numbers: [dynamic]uint, i, sum, total: uint) -> uint {
  if sum > total do return 0
  if i >= len(numbers) {
    return sum if sum == total else 0
  }
  v := calc_rec(numbers, i + 1, sum + numbers[i], total)
  if v == total do return v
  v = calc_rec(numbers, i + 1, sum * numbers[i], total)
  if v == total do return v
  v = calc_rec(numbers, i + 1, concat(sum, numbers[i]), total)
  if v == total do return v
  return 0
}

calc_sum_2 :: proc(numbers: [dynamic]uint, total: uint) -> uint {
  return calc_rec(numbers, 1, numbers[0], total)
}
