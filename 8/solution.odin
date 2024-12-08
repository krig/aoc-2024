package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"

Vec2 :: distinct [2]int

Antenna :: struct {
  p: Vec2,
  f: rune,
}

World :: struct {
  w: int,
  h: int,
  antennas: [dynamic]Antenna
}

INPUT :: #config(INPUT, "input.txt")

main :: proc() {
  world := parse(#load(INPUT, string))
  defer free_world(world)

  fmt.println(count_antinodes(world))
}

parse :: proc(input: string) -> ^World {
  ta := context.temp_allocator
  defer free_all(ta)
  world := new(World)
  world.w = strings.index_byte(input, '\n')
  world.h = strings.count(input, "\n")

  y := 0
  for line in strings.split_lines(input, ta) {
    for r, x in line {
      switch r {
      case 'a'..='z', 'A'..='Z', '0'..='9':
        append(&world.antennas, Antenna{Vec2{x, y}, r})
      }
    }
    y += 1
  }
  return world
}

free_world :: proc(world: ^World) {
  delete(world.antennas)
  free(world)
}

inside :: proc(world: ^World, p: Vec2) -> bool{
  return (p.x >= 0 && p.x < world.w) && (p.y >= 0 && p.y < world.h)
}

antinodes :: proc(world: ^World, a, b: ^Antenna) -> (Maybe(Vec2), Maybe(Vec2)) {
  dx, dy := a.p.x - b.p.x, a.p.y - b.p.y

  an1 := Vec2{b.p.x - dx, b.p.y - dy}
  an2 := Vec2{a.p.x + dx, a.p.y + dy}

  return inside(world, an1) ? an1 : nil, inside(world, an2) ? an2 : nil
}

count_antinodes :: proc(world: ^World) -> int {
  ans: [dynamic]Vec2
  for &antenna in world.antennas {
    for &other in world.antennas {
      if antenna.f == other.f && other != antenna {
        an1, an2 := antinodes(world, &antenna, &other)
        an1v, an1ok := an1.?
        if an1ok && !slice.contains(ans[:], an1v) {
          append(&ans, an1v)
        }
        an2v, an2ok := an2.?
        if an2ok && !slice.contains(ans[:], an2v) {
          append(&ans, an2v)
        }
      }
    }
  }
  return len(ans)
}
