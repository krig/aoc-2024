#!/usr/bin/env janet

(def mul-grammar (peg/compile
  ~{:num (/ (capture :d+) ,scan-number)
    :mul (group (sequence "mul(" :num "," :num ")"))
    :summul (/ :mul ,(fn [mul] (apply * mul)))
    :line (choice :summul 1)
    :main (some :line)}))

(defn main [&]
  (def input (file/read (file/open "input.txt") :all))
  (pp (apply + (peg/match mul-grammar input))))
