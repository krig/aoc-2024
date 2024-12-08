package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"
import "core:container/bit_array"

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

antinodes :: proc(world: ^World, a, b: ^Antenna) -> [dynamic]Vec2 {
  dx, dy := a.p.x - b.p.x, a.p.y - b.p.y

  an1 := Vec2{b.p.x - dx, b.p.y - dy}
  an2 := Vec2{a.p.x + dx, a.p.y + dy}

  ret: [dynamic]Vec2
  for inside(world, an1) {
    append(&ret, an1)
    an1 = Vec2{an1.x - dx, an1.y - dy}
  }
  for inside(world, an2) {
    append(&ret, an2)
    an2 = Vec2{an2.x + dx, an2.y + dy}
  }
  return ret
}

at :: proc(world: ^World, x, y: int) -> (rune, bool) {
  for a in world.antennas {
    if a.p.x == x && a.p.y == y {
      return a.f, true
    }
  }
  return '.', false
}

count_antinodes :: proc(world: ^World) -> int {
  context.allocator = context.temp_allocator
  defer free_all(context.temp_allocator)
  occupied: bit_array.Bit_Array
  for &antenna in world.antennas {
    bit_array.set(&occupied, antenna.p.y*world.h + antenna.p.x)
    for &other in world.antennas {
      if antenna.f != other.f do continue
      if &other == &antenna do continue
      ans := antinodes(world, &antenna, &other)
      for an in ans {
        bit_array.set(&occupied, an.y*world.h + an.x)
      }
    }
  }
  for y in 0..<world.h {
    for x in 0..<world.w {
      r, ok := at(world, x, y)
      if ok {
        fmt.print(r)
      } else if bit_array.get(&occupied, y*world.h + x) {
        fmt.print("#")
      } else {
        fmt.print(".")
      }
    }
    fmt.print("\n")
  }
  total := 0
  it := bit_array.make_iterator(&occupied)
  for i in bit_array.iterate_by_set(&it) {
    total += 1
  }
  return total
}
