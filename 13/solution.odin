package main

import "core:container/bit_array"
import "core:fmt"
import "core:math"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/match"

INPUT :: #config(INPUT, "input.txt")

Vec2 :: distinct [2]u64

Game :: struct {
	a: Vec2,
	b: Vec2,
	prize: Vec2,
}

// solve:
// Ax*x + Bx*y = C
// Ay*x + By*y = D

// x = (C - Bx*y)/Ax = (D - By*y)/Ay
// y = (C - Ax*x)/Bx = (D - Ay*x)/By
// y = (D - Ay*((C - Bx*y)/Ax))/By
// By*y = D - Ay*((C - Bx*y)/Ax)
// By*y + Ay*((C - Bx*y)/Ax) = D
// Ax*By*y + Ay*(C - Bx*y) = D*Ax
// Ax*By*y + Ay*C - Ay*Bx*y = D*Ax
// Ax*By*y - Ay*Bx*y = D*Ax - Ay*C
// y = (D*Ax - Ay*C)/(Ax*By - Ay*Bx)

// y = (C - Ax*((D - By*y)/Ay))/Bx
// Bx*y = C - Ax*((D - By*y)/Ay)
// Bx*y + (Ax/Ay)*(D - By*y) = C
// Ay*Bx*y - Ax*By*y = C*Ay - Ax*D
// y = (C*Ay - Ax*D)/(Ay*Bx - Ax*By)

main :: proc() {
	games := parse(#load(INPUT, string))

	tokens :i128 = 0

	for g in games {
		x1, y1 :i128= 0, 0
		den := i128(g.a.x)*i128(g.b.y) - i128(g.a.y)*i128(g.b.x)
		if den != 0 {
			y := ((i128(g.prize.y)*i128(g.a.x)) - (i128(g.a.y)*i128(g.prize.x))) / den
			x := (i128(g.prize.x) - i128(g.b.x)*i128(y))/i128(g.a.x)
			x1, y1 = x, y
		}

		if (i128(g.a.x)*x1 + i128(g.b.x)*y1 == i128(g.prize.x) &&
			i128(g.a.y)*x1 + i128(g.b.y)*y1 == i128(g.prize.y)) {
			fmt.println(g, x1, y1)
			tokens += x1*3 + y1
		}
	}

	fmt.println("Tokens spent:", tokens)
}

parse :: proc(input: string) -> [dynamic]Game {
	ta := context.temp_allocator
	defer free_all(ta)
	ret := make([dynamic]Game, 0, 64)
	curr :Game
	parts := 0

	for line in strings.split_lines(input, ta) {
		if strings.has_prefix(line, "Button A: ") {
			curr.a = scan_pvec2(line)
			parts += 1
		} else if strings.has_prefix(line, "Button B: ") {
			curr.b = scan_pvec2(line)
			parts += 1
		} else if strings.has_prefix(line, "Prize: ") {
			curr.prize = scan_vec2(line)
			curr.prize.x += 10000000000000
			curr.prize.y += 10000000000000
			parts += 1
		}

		if parts == 3 {
			append(&ret, curr)
			parts = 0
		}
	}
	return ret
}

scan_pvec2 :: proc(s: string) -> Vec2 {
	xs := strings.index(s, "X+") + 2
	xe := strings.index(strings.cut(s, xs), ", Y+")
	return Vec2{
		u64(strconv.atoi(strings.cut(s, xs, xe))),
		u64(strconv.atoi(strings.cut(s, xs + xe + 4))),
	}
}

scan_vec2 :: proc(s: string) -> Vec2 {
	xs := strings.index(s, "X=") + 2
	xe := strings.index(strings.cut(s, xs), ", Y=")
	return Vec2{
		u64(strconv.atoi(strings.cut(s, xs, xe))),
		u64(strconv.atoi(strings.cut(s, xs + xe + 4))),
	}
}
