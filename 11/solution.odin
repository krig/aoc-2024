package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"

main :: proc() {
	input := #load("input.txt", string)
	//input := "125 17"

	stones: [dynamic]uint
	defer delete(stones)
	parse(&input, &stones)
	total := 0
	for s in stones {
		context.allocator = context.temp_allocator
		defer free_all(context.temp_allocator)
		ston:= [dynamic]uint{s}
		for n in 0..<25 {
			blink(&ston)
		}
		total += len(ston)
		fmt.println(s, len(ston))
	}
	fmt.println("len =", total)
}

parse :: proc(input: ^string, output: ^[dynamic]uint) {
	for n in strings.split_multi_iterate(input, []string{" ", "\n"}) {
		if len(n) > 0 {
			append(output, uint(strconv.atoi(n)))
		}
	}
}

blink :: proc(data: ^[dynamic]uint) {
	for i := 0; i < len(data); i += 1 {
		if data[i] == 0 {
			data[i] = 1
		} else {
			nd := ndigits(data[i])
			if even(nd) {
				a, b := split_at(data[i], nd)
				data[i] = a
				inject_at(data, i+1, b)
				i += 1
			} else {
				data[i] *= 2024
			}
		}
	}
}

ndigits :: proc(n: uint) -> uint {
	c :uint= 0
	for m :uint = 1; m <= n; m *= 10 {
		c += 1
	}
	return c
}

even :: proc(n: uint) -> bool {
	return n % 2 == 0
}

split_at :: proc(n, c: uint) -> (uint, uint) {
	h :uint= c / 2
	p :uint= uint(math.pow10(f64(h)))
	a :uint= n / p
	return a, n-(a * p)
}
