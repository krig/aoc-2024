package main

import "core:fmt"
import "core:strings"
import "core:slice"

main :: proc() {
	fmt.println("count=", trailheads(#load("input.txt", string)))
}

trailheads :: proc(input: string) -> uint {
	m := parse(input)
	defer map_delete(m)

	score :uint = 0
	for goal in m.goals {
		score += seek(m, goal, goal, 10)
	}
	return score
}

seek :: proc(m: ^Heightmap, start: Vec2, pos: Vec2, from: u8) -> uint {
	if pos.x < 0 || pos.x >= m.w || pos.y < 0 || pos.y >= m.h do return 0
	curr := at(m, pos.x, pos.y)^
	if from - curr != 1 do return 0
	if curr == 0 do return 1
	ret :uint= 0
	ret += seek(m, start, {pos.x-1, pos.y}, curr)
	ret += seek(m, start, {pos.x+1, pos.y}, curr)
	ret += seek(m, start, {pos.x, pos.y+1}, curr)
	ret += seek(m, start, {pos.x, pos.y-1}, curr)
	return ret
}

parse :: proc(input: string) -> ^Heightmap {
	using strings
	m := new(Heightmap)
	m.w, m.h = index_byte(input, '\n'), count(input, "\n")
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
	delete(m.tiles)
	delete(m.goals)
	free(m)
}

Heightmap :: struct {
	tiles: [dynamic]u8,
	goals: [dynamic]Vec2,
	w: int,
	h: int,
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
