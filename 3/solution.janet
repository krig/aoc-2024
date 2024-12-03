#!/usr/bin/env janet

(var enabled true)

(def grammar (peg/compile
  ~{:num (number :d+)
    :mul (/ (group (* "mul(" :num "," :num ")")) ,|(apply * $))
    :do (/ "do()" ,|(do (set enabled true) 0))
    :dont (/ "don't()" ,|(do (set enabled false) 0))
    :maybe-mul (/ :mul ,|(if enabled $ 0))
    :main (some (+ :maybe-mul :do :dont 1))}))

(defn main [&]
  (pp (sum (peg/match grammar (slurp "input.txt")))))
