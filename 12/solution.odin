package main

import "core:container/bit_array"
import "core:fmt"
import "core:math"
import "core:slice"
import "core:strconv"
import "core:strings"

SAMPLE :: `RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
`

SAMPLE2 :: `AAAA
BBCD
BBCC
EEEC
`

SAMPLE3 :: `OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
`

INPUT :: #config(INPUT, "input.txt")

Board :: struct {
  data: []u8,
  region: []u32,
  w: int,
  h: int,
}

main :: proc() {
	input := #load(INPUT, string)
  //input := SAMPLE
  board := parse(input)
  defer release(board)
  fmt.println("board", board.w, board.h)

  total :uint = 0

  for y in 0..<board.h {
    for x in 0..<board.w {
      total += sum_region(board, x, y)
    }
  }

  fmt.println("total fence price =", total)
}

parse :: proc(data: string) -> ^Board {
  board := new(Board)
	board.w = strings.index_byte(data, '\n')
	board.h = strings.count(data, "\n")
  board.data = make([]u8, board.w*board.h)
  board.region = make([]u32, board.w*board.h)

  x, y := 0, 0
  for r in data {
    if r == '\n' {
      x, y = 0, y + 1
    } else if y*board.h + x >= len(board.data) {
      fmt.println("outside the board", board, x, y, r)
      break
    } else {
      board.data[y*board.h + x] = u8(r)
      x += 1
    }
  }

  return board
}

printreg :: proc(board: ^Board, reg: u32) {
  for y in -1..=board.h {
    for x in -1..=board.w {
      if region(board, x, y) == reg {
        fmt.print(rune(color(board, x, y)))
      } else {
        fmt.print('.')
      }
    }
    fmt.print('\n')
  }
}

release :: proc(board: ^Board) {
  delete(board.data)
  free(board)
}

sum_region :: proc(board: ^Board, x, y: int) -> uint {
  if region(board, x, y) != 0 do return 0
  clr := color(board, x, y)
  reg :u32 = 1000 + u32(y*board.h + x)
  area := sum_area(board, x, y, clr, reg)
  peri := sum_peri(board, reg)
  side := sum_side(board, reg)
  fmt.println("region =", reg, rune(clr), "area =", area, "side =", side)
  return area * side
}

sum_area :: proc(board: ^Board, x, y: int, clr: u8, reg: u32) -> uint {
  if color(board, x, y) != clr do return 0
  if region(board, x, y) != 0 do return 0
  board.region[y*board.h + x] = reg
  area :uint = 1
  area += sum_area(board, x + 1, y, clr, reg)
  area += sum_area(board, x, y + 1, clr, reg)
  area += sum_area(board, x - 1, y, clr, reg)
  area += sum_area(board, x, y - 1, clr, reg)
  return area
}

sum_peri :: proc(board: ^Board, reg: u32) -> uint {
  peri :uint = 0
  for y in -1..=board.h {
    for x in -1..=board.w {
      if region(board, x, y) != reg {
        if region(board, x-1, y) == reg do peri += 1
        if region(board, x+1, y) == reg do peri += 1
        if region(board, x, y-1) == reg do peri += 1
        if region(board, x, y+1) == reg do peri += 1
      }
    }
  }
  return peri
}

sum_side :: proc(board: ^Board, reg: u32) -> uint {
  printreg(board, reg)
  side :uint = 0
  for y in -1..=board.h {
    above, below := 0, 0
    for x in -1..=board.w {
      if region(board, x, y) != reg {
        if region(board, x, y-1) == reg {
          if below == 0 {
            side += 1
            below = 1
          }
        } else {
          below = 0
        }
        if region(board, x, y+1) == reg {
          if above == 0 {
            side += 1
            above = 1
          }
        } else {
          above = 0
        }
      } else {
        above, below = 0, 0
      }
    }
  }
  for x in -1..=board.w {
    left, right := 0, 0
    for y in -1..=board.h {
      if region(board, x, y) != reg {
        if region(board, x-1, y) == reg {
          if left == 0 {
            side += 1
            left = 1
          }
        } else {
          left = 0
        }
        if region(board, x+1, y) == reg {
          if right == 0 {
            side += 1
            right = 1
          }
        } else {
          right = 0
        }
      } else {
        left, right = 0, 0
      }
    }
  }
  return side
}

color :: proc(board: ^Board, x, y: int) -> u8 {
  if x < 0 || y < 0 || x >= board.w || y >= board.h do return 0xff
  return board.data[y*board.h + x]
}

region :: proc(board: ^Board, x, y: int) -> u32 {
  if x < 0 || y < 0 || x >= board.w || y >= board.h do return 0
  return board.region[y*board.h + x]
}
