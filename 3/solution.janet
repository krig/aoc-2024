#!/usr/bin/env janet

(var enabled true)

(def mul-grammar (peg/compile
  ~{:num (/ (capture :d+) ,scan-number)
    :mul (group (sequence "mul(" :num "," :num ")"))
    :do (/ "do()" ,(fn [] (set enabled true) 0))
    :dont (/ "don't()" ,(fn [] (set enabled false) 0))
    :summul (/ :mul ,(fn [mul] (if enabled (apply * mul) 0)))
    :line (choice :summul :do :dont 1)
    :main (some :line)}))

(defn main [&]
  (def input (file/read (file/open "input.txt") :all))
  (pp (apply + (peg/match mul-grammar input))))
