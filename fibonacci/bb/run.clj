(require '[languages.benchmark :as benchmark])

(defn- fibonacci [n]
  (if (< n 2)
    n
    (+ (fibonacci (- n 1))
       (fibonacci (- n 2)))))

(let [run-ms (parse-long (first *command-line-args*))
      u (parse-long (second *command-line-args*))]
  (-> (benchmark/run #(fibonacci u) run-ms)
      benchmark/format-results
      println))
