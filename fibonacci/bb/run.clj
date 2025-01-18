(require '[languages.benchmark :as benchmark])

(defn- fibonacci [n]
  (case n
    0 0
    1 1
    (+ (fibonacci (- n 1))
       (fibonacci (- n 2)))))

(defn main [u]
  (reduce + (map fibonacci (range u))))

(let [run-ms (parse-long (first *command-line-args*))
      u (parse-long (second *command-line-args*))]
  (-> (benchmark/run #(main u) run-ms)
      benchmark/format-results
      println))
