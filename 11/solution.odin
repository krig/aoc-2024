package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

main :: proc() {
	input := #load("input.txt", string)
	//input := "125 17"
	rounds := 75

	stones:= make(map[uint]uint)
	defer delete(stones)
	parse(&input, &stones)
	for _ in 0..<rounds do blink(&stones)
	total :uint= 0
	for _, v in stones do total += v
	fmt.println("len =", total)
}

parse :: proc(input: ^string, output: ^map[uint]uint) {
	for n in strings.split_multi_iterate(input, []string{" ", "\n"}) {
		if len(n) > 0 {
			num := uint(strconv.atoi(n))
			output[num] = output[num] + 1
		}
	}
}

blink :: proc(data: ^map[uint]uint) {
	newdata := make(map[uint]uint)
	for n in data {
		if n == 0 {
			newdata[1] += data[n]
		} else {
			nd := ndigits(n)
			if even(nd) {
				a, b := split_at(n, nd)
				newdata[a] += data[n]
				newdata[b] += data[n]
			} else {
				newdata[n * 2024] += data[n]
			}
		}
	}
	delete(data^)
	data^ = newdata
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
