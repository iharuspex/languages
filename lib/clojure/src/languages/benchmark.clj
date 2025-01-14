(ns languages.benchmark)

(set! *unchecked-math* :warn-on-boxed)

(defn run [^long run-ms f]
  (let [t-start (System/currentTimeMillis)
        t-stop (+ t-start (long (* run-ms)))
        rs (reduce (fn [results ^long i]
                     (let [result (f)
                           t (System/currentTimeMillis)]
                       (if (< t t-stop)
                         (conj results [i t result])
                         (reduced (conj results [i t result])))))
                   []
                   (range))
        [^long i ^long t result] (last rs)
        elapsed-time (- t t-start)
        mean-time (/ elapsed-time (inc i))]
    [result (inc i) mean-time]))