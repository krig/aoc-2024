package main

import "core:fmt"
import "core:strings"
import "core:container/bit_array"

Dir :: enum { N, E, S, W }

Game :: struct {
  w: int,
  h: int,
  gx: int,
  gy: int,
  gd: Dir,
  obstacles: bit_array.Bit_Array,
  visited: bit_array.Bit_Array,
}

visit :: proc(game: ^Game, x, y: int) {
  bit_array.set(&game.visited, y*game.h + x)
}

obstacle_at :: proc(game: ^Game, x, y: int) -> bool {
  return bit_array.get(&game.obstacles, y * game.h + x)
}

move_guard :: proc(game: ^Game) -> bool {
    switch game.gd {
    case .N:
      if game.gy == 0 do return false
      if obstacle_at(game, game.gx, game.gy - 1) {
        game.gd = .E
      } else {
        game.gy -= 1
      }
    case .S:
      if game.gy == (game.h-1) do return false
      if obstacle_at(game, game.gx, game.gy + 1) {
        game.gd = .W
      } else {
        game.gy += 1
      }
    case .W:
      if game.gx == 0 do return false
      if obstacle_at(game, game.gx - 1, game.gy) {
        game.gd = .N
      } else {
        game.gx -= 1
      }
    case .E:
      if game.gx == (game.w-1) do return false
      if obstacle_at(game, game.gx + 1, game.gy) {
        game.gd = .S
      } else {
        game.gx += 1
      }
    }
    return true
}

main :: proc() {
  game := parse_map(#load("input.txt", string))
  defer free(game)
  fmt.println(game.w, game.h)

  loop: for {
    visit(game, game.gx, game.gy)
    if !move_guard(game) do break loop
  }


  it := bit_array.make_iterator(&game.visited)
  count := 0
  for i in bit_array.iterate_by_set(&it) {
    count += 1
  }
  fmt.println("visited:", count)
}

parse_map :: proc(input: string) -> ^Game {
  game := new(Game)
  game.w = strings.index_byte(input, '\n')
  game.h = strings.count(input, "\n")
  defer free_all(context.temp_allocator)

  y := 0
  for line in strings.split_lines(input, context.temp_allocator) {
    for r, x in line {
      switch r {
      case '#':
        bit_array.set(&game.obstacles, y*game.h + x)
      case '^':
        game.gx = x
        game.gy = y
        game.gd = .N
      }
    }
    y += 1
  }

  return game
}
