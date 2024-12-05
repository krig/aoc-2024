#!/usr/bin/env janet

(defn read-input []
  (def page-order (peg/compile ~{:main (* (number :d+) "|" (number :d+))}))
  (def page-set (peg/compile ~{:main (* (number :d+) (any (* "," (number :d+))))}))
  (let [page-sets @[] before-rules @{}]
    (with [input (file/open "input.txt") file/close]
      (each line (file/lines input)
        (if-let [[before after] (peg/match page-order line)]
          (if-let [rule (get before-rules after)]
            (set (rule before) true)
            (put before-rules after @{ before true }))
          (if-let [pageset (peg/match page-set line)]
            (array/push page-sets pageset)))))
    @[page-sets before-rules]))

(defn main [&]
  (defn median [ind]
    (get ind (math/floor (/ (length ind) 2))))
  (let [[page-sets before-rules] (read-input)]
    (defn sort-page-set [page-set]
      (sort page-set
            (fn [a b]
              (if-let [rule (get before-rules b)]
                (get rule a)))))
    (defn incorrect? [page-set]
      (label incorrect
             (loop [i :range [0 (length page-set)]]
               (if-let [rule (get before-rules (get page-set i))]
                 (loop [j :range [i (length page-set)]]
                   (if (get rule (get page-set j))
                     (return incorrect true)))))))
    (pp
      (reduce + 0
              (map (fn [page-set]
                     (if (not (incorrect? page-set))
                       (median page-set)
                       0))
                   page-sets)))
    (pp
      (reduce + 0
              (map (fn [page-set]
                     (if (incorrect? page-set)
                       (median (sort-page-set page-set))
                       0))
                   page-sets)))))
