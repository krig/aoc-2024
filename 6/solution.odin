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

move_guard :: proc(game: ^Game, new_obstacle: int = -1) -> bool {
    switch game.gd {
    case .N:
      if game.gy == 0 do return false
      if obstacle_at(game, game.gx, game.gy - 1, new_obstacle) {
        game.gd = .E
      } else {
        game.gy -= 1
      }
    case .S:
      if game.gy == (game.h-1) do return false
      if obstacle_at(game, game.gx, game.gy + 1, new_obstacle) {
        game.gd = .W
      } else {
        game.gy += 1
      }
    case .W:
      if game.gx == 0 do return false
      if obstacle_at(game, game.gx - 1, game.gy, new_obstacle) {
        game.gd = .N
      } else {
        game.gx -= 1
      }
    case .E:
      if game.gx == (game.w-1) do return false
      if obstacle_at(game, game.gx + 1, game.gy, new_obstacle) {
        game.gd = .S
      } else {
        game.gx += 1
      }
    }
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

find_all_loop_places :: proc(game: ^Game) -> int #no_bounds_check {
  using bit_array
  places := 0
  gx, gy, gd := game.gx, game.gy, game.gd
  n: Bit_Array
  e: Bit_Array
  s: Bit_Array
  w: Bit_Array
  for new_obstacle := 0; new_obstacle < game.w*game.h; new_obstacle += 1 {
    game.gx, game.gy, game.gd = gx, gy, gd
    if new_obstacle == gy*game.h + gx do continue
    if bit_array.get(&game.obstacles, new_obstacle) do continue
    loop: for {
      switch game.gd {
      case .N:
        set(&n, game.gy*game.h + game.gx)
      case .S:
        set(&s, game.gy*game.h + game.gx)
      case .E:
        set(&e, game.gy*game.h + game.gx)
      case. W:
        set(&w, game.gy*game.h + game.gx)
      }
      if !move_guard(game, new_obstacle) do break loop
      // check if last move is a repeat
      switch game.gd {
      case .N:
        if get(&n, game.gy*game.h + game.gx) {
          places += 1
          break loop
        }
      case .S:
        if get(&s, game.gy*game.h + game.gx) {
          places += 1
          break loop
        }
      case .E:
        if get(&e, game.gy*game.h + game.gx) {
          places += 1
          break loop
        }
      case .W:
        if get(&w, game.gy*game.h + game.gx) {
          places += 1
          break loop
        }
      }
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
  //fmt.println(game.w, game.h)
  //gx, gy, gd := game.gx, game.gy, game.gd
  //fmt.println("visited:", count_visited(game))
  //game.gx, game.gy, game.gd = gx, gy, gd
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
