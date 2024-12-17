package ko

import "base:intrinsics"
import ba "core:container/bit_array"

count_set :: proc(array: ^ba.Bit_Array) -> u64 {
  total :u64 = 0
  for bit in array.bits {
    total += intrinsics.count_ones(bit)
  }
	return total
}
