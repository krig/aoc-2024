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

	fmt.println(defrag_block(input))
	//test_input :: "2333133121414131402"
	//fmt.println(defrag_block(test_input))
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

Block :: struct {
	id: int,
	length: int,
}

defrag_block :: proc(text: string) -> uint {
	curr_id := 0
	input_len := len(text)
	defragged: [dynamic]Block
	defer delete(defragged)
	for i := 0; i < input_len; i += 2 {
		file_len := int(text[i]-'0')
		free_len := i < input_len - 1 ? int(text[i+1]-'0') : 0
		if file_len > 0 {
			append(&defragged, Block{curr_id, file_len})
			curr_id += 1
		}
		if free_len > 0 {
			append(&defragged, Block{-1, free_len})
		}
	}
	read_pos := len(defragged)-1
	for {
		//fmt.println(defragged, len(defragged), read_pos)
		insert_pos := 0
		for read_pos >= 0 && defragged[read_pos].id == -1 {
			read_pos -= 1
		}
		if read_pos < 0 do break
		if defragged[read_pos].id == -1 do break
		for  {
			for insert_pos < read_pos && insert_pos < len(defragged) && defragged[insert_pos].id != -1 {
				insert_pos += 1
			}
			if insert_pos < read_pos && insert_pos < len(defragged) && defragged[insert_pos].length < defragged[read_pos].length {
				insert_pos += 1
			} else {
				break
			}
		}
		if insert_pos >= len(defragged) {
			continue
		}
		if defragged[insert_pos].id != -1 {
			read_pos -= 1
			continue
		}
		//fmt.println("moving", read_pos, defragged[read_pos], "to", insert_pos, defragged[insert_pos])
		if defragged[read_pos].length == defragged[insert_pos].length {
			defragged[insert_pos] = defragged[read_pos]
			defragged[read_pos] = Block{-1, defragged[read_pos].length}
		} else {
			// split the block
			new_free := Block{-1, defragged[insert_pos].length - defragged[read_pos].length}
			defragged[insert_pos].id = defragged[read_pos].id
			defragged[insert_pos].length = defragged[read_pos].length
			defragged[read_pos] = Block{-1, defragged[read_pos].length}
			inject_at(&defragged, insert_pos+1, new_free)
			read_pos += 1
		}
	}
	//fmt.println(defragged)
	total :uint = 0
	curr :uint = 0
	for b, i in defragged {
		if b.id == -1 {
			curr += uint(b.length)
			continue
		}
		for n in 0..<b.length {
			total += uint(b.id)*curr
			curr += 1
		}
	}
	return total
}

