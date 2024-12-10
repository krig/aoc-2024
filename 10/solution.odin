package main

import "core:fmt"
import "core:strings"

Vec2 :: distinct [2]int

Heightmap :: struct {
	tiles: [dynamic]u8,
	goals: [dynamic]Vec2,
	w: int,
	h: int,
}

main :: proc() {
	fmt.println("count=", trailheads(#load("input.txt", string)))
}

trailheads :: proc(input: string) -> uint {
	context.allocator = context.temp_allocator
	defer free_all(context.temp_allocator)
	m := parse(input)

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

at :: proc(m: ^Heightmap, x, y: int) -> ^u8 {
	return &m.tiles[y*m.h + x]
}

parse :: proc(input: string) -> ^Heightmap {
	m := new(Heightmap)
	m.w, m.h = strings.index_byte(input, '\n'), strings.count(input, "\n")
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
