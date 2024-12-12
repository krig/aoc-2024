package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

Key :: struct {
  stone: uint,
  round: uint,
}

main :: proc() {
	input := #load("input.txt", string)
	//input := "125 17"
	rounds :uint = 75

	stones: [dynamic]uint
	defer delete(stones)
	parse(&input, &stones)
  cache := make(map[Key]uint)
	total :uint= 0
	for v in stones do total += memoblink(Key{v, rounds}, &cache)
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

memoblink :: proc(key: Key, cache: ^map[Key]uint) -> uint {
  if key in cache^ do return cache[key]

  if key.stone == 0 {
    if key.round == 1 {
      cache[key] = 1
      return 1
    }
    v := memoblink(Key {1, key.round - 1}, cache)
    cache[key] = v
    return v
  }
  nd := ndigits(key.stone)
  if even(nd) {
    if key.round == 1 {
      cache[key] = 2
      return 2
    }
    a, b := split_at(key.stone, nd)
    v := memoblink(Key { a, key.round - 1 }, cache) + memoblink(Key {b, key.round - 1}, cache)
    cache[key] = v
    return v
  }
  if key.round == 1 {
    cache[key] = 1
    return 1
  }
  v := memoblink(Key { key.stone * 2024, key.round - 1 }, cache)
  cache[key] = v
  return v
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
	p :uint = uint(math.pow10(f64(h)))
	a :uint = n / p
	return a, n - (a * p)
}
