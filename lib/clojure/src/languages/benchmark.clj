(ns languages.benchmark)

(set! *unchecked-math* :warn-on-boxed)

(defn run [^long run-ms f]
  (let [run-ns (* 1000000 run-ms)
        rs (reduce (fn [results ^long i]
                     (let [^long last-tet (or (first (last results)) 0)
                           t0 (System/nanoTime)
                           result (f)
                           t1 (System/nanoTime)
                           elapsed-time (- t1 t0)
                           total-elapsed-time (+ last-tet elapsed-time)]
                       (if (< total-elapsed-time run-ns)
                         (conj results [total-elapsed-time elapsed-time i result])
                         (reduced (conj results [total-elapsed-time elapsed-time i result])))))
                   []
                   (range))
        [^long total-elapsed-time ^long t ^long i result] (last rs)
        mean-time (/ total-elapsed-time (inc i))]
    [result (inc i) (/ mean-time 1000000)]))

(comment
  (run 1 #(reduce + (range 1000000)))
  :rcf)

