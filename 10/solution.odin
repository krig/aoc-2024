package main

import "core:fmt"
import "core:strings"
import "core:slice"

main :: proc() {
	fmt.println("count=", trailheads(#load("input.txt", string)))
	//for example in EXAMPLES {
	//	fmt.println("expected=", example.expected, "count=", trailheads(example.input))
	//}
}

trailheads :: proc(input: string) -> uint {
	m := parse(input)
	defer map_delete(m)

	for goal in m.goals {
		fmt.println("seek", goal)
		seek(m, goal, goal, 10)
	}
	score :uint= 0
	for key, value in m.paths {
		score += len(value)
	}
	return score
}

seek :: proc(m: ^Heightmap, start: Vec2, pos: Vec2, from: u8) {
	if pos.x < 0 || pos.x >= m.w || pos.y < 0 || pos.y >= m.h do return
	curr := at(m, pos.x, pos.y)^
	if from - curr != 1 do return
	if curr == 0 {
		poses, ok := &m.paths[start]
		if ok {
			//if !slice.contains(poses[:], pos) {
			fmt.println("goal", pos)
			append(poses, pos)
			//} else {
			//	fmt.println("dup", pos)
			//}
		} else {
			fmt.println("goal!", pos)
			stuff := make([dynamic]Vec2)
			append(&stuff, pos)
			m.paths[start] = stuff
		}
	}
	seek(m, start, {pos.x-1, pos.y}, curr)
	seek(m, start, {pos.x+1, pos.y}, curr)
	seek(m, start, {pos.x, pos.y+1}, curr)
	seek(m, start, {pos.x, pos.y-1}, curr)
}

parse :: proc(input: string) -> ^Heightmap {
	using strings
	m := new(Heightmap)
	m.w, m.h = index_byte(input, '\n'), count(input, "\n")
	m.paths = make(map[Vec2][dynamic]Vec2)
	resize(&m.tiles, m.w * m.h)
	x, y := 0, 0
	for r in input {
		switch r {
		case '0'..='9':
			if r == '9' do append(&m.goals, Vec2{x, y})
			at(m, x, y)^ = u8(r - '0')
			x += 1
		case '\n':
			x, y = 0, y + 1
		case:
			at(m, x, y)^ = 0xff
			x += 1
		}
	}
	return m
}

at :: proc(m: ^Heightmap, x, y: int) -> ^u8 {
	return &m.tiles[y*m.h + x]
}

map_delete :: proc(m: ^Heightmap) {
	for _, value in m.paths {
		delete(value)
	}
	delete(m.tiles)
	delete(m.goals)
	delete(m.paths)
	free(m)
}

Heightmap :: struct {
	tiles: [dynamic]u8,
	goals: [dynamic]Vec2,
	w: int,
	h: int,
	paths: map[Vec2][dynamic]Vec2
}

Vec2 :: distinct [2]int

Example :: struct {
	input:    string,
	expected: int,
}

EXAMPLES :: []Example {
	{
		`89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
`,
		36,
	},
}
