package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

Key :: struct {
  stone: uint,
  round: uint,
}

cache := make(map[Key]uint)

main :: proc() {
  defer delete(cache)
	input := #load("input.txt", string)
	//input := "125 17"
	rounds :uint = 75

	stones: [dynamic]uint
	defer delete(stones)
	parse(&input, &stones)
	total :uint= 0
	for v in stones do total += memoblink(Key{v, rounds})
	fmt.println("len =", total)
}

parse :: proc(input: ^string, output: ^[dynamic]uint) {
	for n in strings.split_multi_iterate(input, []string{" ", "\n"}) {
		if len(n) > 0 {
			num := uint(strconv.atoi(n))
      append(output, num)
		}
	}
}

memoblink :: proc(key: Key) -> uint {
  if key in cache do return cache[key]

  if key.round == 1 {
    if key.stone == 0 do return memo(key, 1)
    nd := ndigits(key.stone)
    if even(nd) do return memo(key, 2)
    return memo(key, 1)
  }

  if key.stone == 0 {
    return memo(key, memoblink(Key{1, key.round - 1}))
  }
  nd := ndigits(key.stone)
  if even(nd) {
    a, b := split_at(key.stone, nd)
    return memo(key, memoblink(Key{ a, key.round - 1 }) + memoblink(Key{b, key.round - 1}))
  }
  return memo(key, memoblink(Key{ key.stone * 2024, key.round - 1 }))
}

memo :: proc(key: Key, val: uint) -> uint {
  cache[key] = val
  return val
}

ndigits :: proc(n: uint) -> uint {
	c :uint = 0
	for m :uint = 1; m <= n; m *= 10 do c += 1
	return c
}

even :: proc(n: uint) -> bool {
	return n % 2 == 0
}

split_at :: proc(n, c: uint) -> (uint, uint) {
	h :uint = c / 2
	p :uint = uint(math.pow10(f32(h)))
	a :uint = n / p
	return a, n - (a * p)
}
