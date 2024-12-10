package main

import "core:fmt"

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
	for goal in m.goals do score += seek(m, goal, 10)
	return score
}

parse :: proc(input: string) -> ^Heightmap {
	m := new(Heightmap)
	m.w, m.h = 0, 0
	ngoals := 0
	for r, i in input {
		if r == '\n' {
			if m.w == 0 do m.w = i
			m.h += 1
		} else if r == '9' {
			ngoals += 1
		}
	}
	resize(&m.tiles, m.w * m.h)
	reserve(&m.goals, ngoals)
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

inside :: proc(m: ^Heightmap, x, y: int) -> bool {
	return x >= 0 && x < m.w && y >= 0 && y < m.h
}

seek :: proc(m: ^Heightmap, pos: Vec2, from: u8) -> uint {
	if !inside(m, pos.x, pos.y) do return 0
	curr := at(m, pos.x, pos.y)^
	if from - curr != 1 do return 0
	if curr == 0 do return 1
	ret :uint= 0
	ret += seek(m, {pos.x-1, pos.y}, curr)
	ret += seek(m, {pos.x+1, pos.y}, curr)
	ret += seek(m, {pos.x, pos.y+1}, curr)
	ret += seek(m, {pos.x, pos.y-1}, curr)
	return ret
}
