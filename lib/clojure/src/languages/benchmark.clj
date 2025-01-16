(ns languages.benchmark)

(defn- stats
  "Returns stats in ms for input in ns"
  [total-elapsed-time elapsed-times]
  (let [runs (count elapsed-times)
        mean-ns (/ total-elapsed-time runs)
        min-ns (reduce min elapsed-times)
        max-ns (reduce max elapsed-times)
        variance (/ (reduce + (map (fn [t]
                                     (Math/pow (- t mean-ns) 2))
                                   elapsed-times))
                    runs)
        std-dev-ns (Math/sqrt variance)]
    {:mean-ms (/ mean-ns 1000000)
     :min-ms (/ min-ns 1000000)
     :max-ms (/ max-ns 1000000)
     :std-dev-ms (/ std-dev-ns 1000000)}))

; Avoid introducing more overhead than necessary in the loop below
(set! *unchecked-math* :warn-on-boxed) 

(defn run 
  "Runs `f` repeatedly measuring the time delta in nanoseconds
   Stops when the sum of the deltas is larger then `run-ms`
   Returns a map with stats and result.
   NB: If `f` takes sub-milliseconds to run, this function can run for very long
       because of the overhead of looping so many times."
  [^long run-ms f]
  (let [run-ns (* 1000000 run-ms)
        runs (loop [results []
                    last-tet 0]
               (let [t0 (System/nanoTime)
                     result (f)
                     t1 (System/nanoTime)
                     elapsed-time (- t1 t0)
                     total-elapsed-time (+ last-tet elapsed-time)
                     timed-result [total-elapsed-time elapsed-time result]]
                 (if (< total-elapsed-time run-ns)
                   (recur (conj results timed-result) total-elapsed-time)
                   (conj results timed-result))))
        [^long total-elapsed-time _ ^long result] (last runs)
        elapsed-times (map second runs)]
    (merge {:runs (count runs)
            :result result}
           (update-vals (stats total-elapsed-time elapsed-times) double))))

(comment
  (run 1000 #(reduce + (range 1000000)))
  :rcf)

