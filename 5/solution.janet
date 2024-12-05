#!/usr/bin/env janet

# read the ordering rules,
# then for each page set:
# - make sure it follows the ordering rules
# - find the middle page number of each correct batch
# - add all the middle page numbers

(def page-order (peg/compile
  ~{:main (* (number :d+) "|" (number :d+))}))

(def page-set (peg/compile
  ~{:main (* (number :d+) (any (* "," (number :d+))))}))

(defn sort-page-set [page-set before-rules]
  (sort page-set (fn [a b]
    (if-let [rule (get before-rules b)]
      (get rule a)))))

(defn main [&]
  (var page-sets @[])
  # before-rules: for each page in rules, every page listed must come before it
  (var before-rules @{})

  (with [input (file/open "input.txt") file/close]
    (each line (file/lines input)
      (if-let [order (peg/match page-order line)]
        (if-let [rule (get before-rules (get order 1))]
          (set (rule (get order 0)) true)
          (put before-rules (get order 1) @{ (get order 0) true }))
        (if-let [pageset (peg/match page-set line)]
          (array/push page-sets pageset)))))

  # for each page: make sure none of the pages after it
  # appear in its before set
  (var page-sum 0)
  (each page-set page-sets
    (var correct true)
    (loop [i :range [0 (length page-set)]]
      (if-let [rule (get before-rules (get page-set i))]
        (loop [j :range [i (length page-set)]]
          (if (get rule (get page-set j))
            (set correct false)))))
    (if (not correct)
      (let [sorted-page-set (sort-page-set page-set before-rules)]
        (set page-sum (+ page-sum (get sorted-page-set (math/floor (/ (length sorted-page-set) 2))))))))

      (pp page-sum))

