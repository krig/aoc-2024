#!/usr/bin/env janet

(var enabled true)

(def mul-grammar (peg/compile
  ~{:num (/ (capture :d+) ,scan-number)
    :mul (/ (group (sequence "mul(" :num "," :num ")")) ,(fn [numbers] (apply * numbers)))
    :do (/ "do()" ,(fn [] (set enabled true) 0))
    :dont (/ "don't()" ,(fn [] (set enabled false) 0))
    :maybe-mul (/ :mul ,(fn [mul] (if enabled mul 0)))
    :line (choice :maybe-mul :do :dont 1)
    :main (some :line)}))

(defn main [&]
  (pp (apply + (peg/match mul-grammar (slurp "input.txt")))))
