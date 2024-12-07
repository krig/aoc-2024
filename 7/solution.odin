package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

main :: proc() {
  lines := strings.split_lines(#load("input.txt", string))
  sum :uint = 0
  for line in lines {
    sum += calc(line)
  }
  fmt.println(sum)
}

calc :: proc(line: string) -> uint {
  context.allocator = context.temp_allocator
  defer free_all(context.temp_allocator)

  head, _, tail := strings.partition(line, ": ")
  total := uint(strconv.atoi(head))
  numbers: [dynamic]uint
  for s in strings.split_iterator(&tail, " ") {
    append(&numbers, uint(strconv.atoi(s)))
  }

  sum := calc_sum(numbers, total)
  if sum == total {
    return sum
  }
  return calc_sum_2(numbers, total)
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
  d := a
  for c := b; c > 0; c /= 10 {
    d *= 10
  }
  return d + b
}

calc_rec :: proc(numbers: [dynamic]uint, i, sum, total: uint) -> uint {
  if i >= len(numbers) {
    if sum == total {
      return sum
    }
    return 0
  }
  v := calc_rec(numbers, i + 1, sum + numbers[i], total)
  if v == total {
    return v
  }
  v = calc_rec(numbers, i + 1, sum * numbers[i], total)
  if v == total {
    return v
  }
  v = calc_rec(numbers, i + 1, concat(sum, numbers[i]), total)
  if v == total {
    return v
  }
  return 0
}

calc_sum_2 :: proc(numbers: [dynamic]uint, total: uint) -> uint {
  return calc_rec(numbers, 1, numbers[0], total)
}
