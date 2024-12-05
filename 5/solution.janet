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
  (defn sort-page-set [page-set before-rules]
    (sort page-set (fn [a b]
                     (if-let [rule (get before-rules b)]
                       (get rule a)))))

  (defn middle [ind]
    (get ind (math/floor (/ (length ind) 2))))

  (let [[page-sets before-rules] (read-input)]
    (pp (reduce + 0 (map (fn [page-set]
      (if (label incorrect
                 (loop [i :range [0 (length page-set)]]
                   (if-let [rule (get before-rules (get page-set i))]
                     (loop [j :range [i (length page-set)]]
                       (if (get rule (get page-set j))
                         (return incorrect true))))))
        (let [sorted-page-set (sort-page-set page-set before-rules)]
          (middle sorted-page-set)) 0)) page-sets)))))
