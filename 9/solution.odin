package main

import "core:container/bit_array"
import "core:fmt"
import "core:math"
import "core:slice"
import "core:strconv"
import "core:strings"

INPUT :: #config(INPUT, "input.txt")

main :: proc() {
	input := #load(INPUT, string)

	fmt.println(defrag(input))
	//test_input :: "2333133121414131402"
	//fmt.println(defrag(test_input))
}

defrag :: proc(text: string) -> uint {
	curr_id := 0
	input_len := len(text)
	defragged: [dynamic]int
	defer delete(defragged)
	for i := 0; i < input_len; i += 2 {
		file_len := text[i]-'0'
		free_len := i < input_len - 1 ? text[i+1]-'0' : 0
		for _ in 0..<file_len {
			append(&defragged, curr_id)
		}
		for _ in 0..<free_len {
			append(&defragged, -1)
		}
		curr_id += 1
	}
	insert_pos := 0
	read_pos := len(defragged)-1
	for read_pos > insert_pos {
		for insert_pos < read_pos && defragged[insert_pos] != -1 {
			insert_pos += 1
		}
		for read_pos > insert_pos && defragged[read_pos] == -1 {
			read_pos -= 1
		}
		if insert_pos >= len(defragged) do break
		if read_pos < 0 do break
		defragged[insert_pos], defragged[read_pos] = defragged[read_pos], defragged[insert_pos]
	}
	total :uint = 0
	for b, i in defragged {
		if b == -1 do break
		total += uint(b)*uint(i)
	}
	return total
}
