package main

import "core:container/bit_array"
import "core:fmt"
import "core:math"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/match"

INPUT :: #config(INPUT, "input.txt")

Vec2 :: distinct [2]i64

Game :: struct {
	a:     Vec2,
	b:     Vec2,
	prize: Vec2,
}

// solve:
// Ax*x + Bx*y = C
// Ay*x + By*y = D

// rewritten:
// y = (D*Ax - Ay*C)/(Ax*By - Ay*Bx)
// x = (C - Bx*y)/Ax

main :: proc() {
	games := parse(#load(INPUT, string))
	expect := [2]i64{33921, 82261957837868}

	for part in 1 ..= 2 {
		tokens: i64 = 0
		for g in games {
			c := g.prize.x + (10000000000000 if part == 2 else 0)
			d := g.prize.y + (10000000000000 if part == 2 else 0)
			den := g.a.x * g.b.y - g.a.y * g.b.x

			if den != 0 {
				y := ((d * g.a.x) - (g.a.y * c)) / den
				x := (c - g.b.x * y) / g.a.x

				if (g.a.x * x + g.b.x * y == c && g.a.y * x + g.b.y * y == d) {
					tokens += x * 3 + y
				}
			}

		}

		if tokens != expect[part - 1] {
			fmt.println("part", part, "got", tokens, "should be", expect[part - 1])
		} else {
			fmt.println("part", part, "=", tokens)
		}
	}
}

parse :: proc(input: string) -> [dynamic]Game {
	ta := context.temp_allocator
	defer free_all(ta)
	ret := make([dynamic]Game, 0, 64)
	curr: Game
	parts := 0

	for line in strings.split_lines(input, ta) {
		if strings.has_prefix(line, "Button A: ") {
			curr.a = scan_vec2(line, '+')
			parts += 1
		} else if strings.has_prefix(line, "Button B: ") {
			curr.b = scan_vec2(line, '+')
			parts += 1
		} else if strings.has_prefix(line, "Prize: ") {
			curr.prize = scan_vec2(line, '=')
			parts += 1
		}

		if parts == 3 {
			append(&ret, curr)
			parts = 0
		}
	}
	return ret
}

scan_vec2 :: proc(s: string, del: u8) -> Vec2 {
	xs := strings.index(s, transmute(string)[]u8{'X', del}) + 2
	xe := strings.index(strings.cut(s, xs), transmute(string)[]u8{',', ' ', 'Y', del})
	return Vec2 {
		i64(strconv.atoi(strings.cut(s, xs, xe))),
		i64(strconv.atoi(strings.cut(s, xs + xe + 4))),
	}
}
