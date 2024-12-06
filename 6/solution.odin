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

obstacle_at :: proc(game: ^Game, x, y, new_obstacle: int) -> bool {
  if y * game.h + x == new_obstacle do return true
  return bit_array.get(&game.obstacles, y * game.h + x)
}

Move :: struct {
  d: Dir,
  dx: int,
  dy: int,
}

moves := [Dir]Move {
  .N = { .E, 0, -1 },
  .E = { .S, 1, 0 },
  .S = { .W, 0, 1 },
  .W = { .N, -1, 0 },
}

move_guard :: proc(game: ^Game, new_obstacle: int = -1) -> bool {
  if moves[game.gd].dx < 0 && game.gx == 0 do return false
  if moves[game.gd].dx > 0 && game.gx == (game.w-1) do return false
  if moves[game.gd].dy < 0 && game.gy == 0 do return false
  if moves[game.gd].dy > 0 && game.gy == (game.h-1) do return false

  for obstacle_at(game, game.gx + moves[game.gd].dx, game.gy + moves[game.gd].dy, new_obstacle) {
    game.gd = moves[game.gd].d
    if moves[game.gd].dx < 0 && game.gx == 0 do return false
    if moves[game.gd].dx > 0 && game.gx == (game.w-1) do return false
    if moves[game.gd].dy < 0 && game.gy == 0 do return false
    if moves[game.gd].dy > 0 && game.gy == (game.h-1) do return false
  }
  game.gx += moves[game.gd].dx
  game.gy += moves[game.gd].dy
  return true
}

count_visited :: proc(game: ^Game) -> int {
  loop: for {
    visit(game, game.gx, game.gy)
    if !move_guard(game) do break loop
  }

  it := bit_array.make_iterator(&game.visited)
  count := 0
  for i in bit_array.iterate_by_set(&it) {
    count += 1
  }
  return count
}

find_all_loop_places :: proc(game: ^Game) -> int {
  using bit_array
  places := 0
  gx, gy, gd := game.gx, game.gy, game.gd
  trail: [Dir]Bit_Array
  defer for dir in Dir {
    destroy(&trail[dir])
  }
  for new_obstacle := 0; new_obstacle < game.w*game.h; new_obstacle += 1 {
    game.gx, game.gy, game.gd = gx, gy, gd
    if new_obstacle == gy*game.h + gx do continue
    if !get(&game.visited, new_obstacle) do continue
    if get(&game.obstacles, new_obstacle) do continue
    nloops := 0
    for dir in Dir {
      clear(&trail[dir])
    }
    loop: for {
      set(&trail[game.gd], game.gy*game.h + game.gx)
      if !move_guard(game, new_obstacle) do break loop
      // check if last move is a repeat
      if get(&trail[game.gd], game.gy*game.h + game.gx) {
        places += 1
        break loop
      }
      nloops += 1
    }
  }
  return places
}

delete_game :: proc(game: ^Game) {
  using bit_array
  destroy(&game.obstacles)
  destroy(&game.visited)
  free(game)
}

main :: proc() {
  game := parse_map(#load("input.txt", string))
  defer delete_game(game)
  fmt.println(game.w, game.h)
  gx, gy, gd := game.gx, game.gy, game.gd
  fmt.println("visited:", count_visited(game))
  game.gx, game.gy, game.gd = gx, gy, gd
  fmt.println("num loop spots:", find_all_loop_places(game))
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
