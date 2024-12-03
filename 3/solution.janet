#!/usr/bin/env janet

(var enabled true)

(def mul-grammar (peg/compile
  ~{:num (/ (capture :d+) ,scan-number)
    :mul (/ (group (sequence "mul(" :num "," :num ")")) ,|(apply * $))
    :do (/ "do()" ,|(do (set enabled true) 0))
    :dont (/ "don't()" ,|(do (set enabled false) 0))
    :maybe-mul (/ :mul ,|(if enabled $ 0))
    :main (some (choice :maybe-mul :do :dont 1))}))

(defn main [&]
  (pp (sum (peg/match mul-grammar (slurp "input.txt")))))
