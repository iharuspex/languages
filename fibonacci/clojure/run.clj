(ns run
  (:gen-class))

(set! *unchecked-math* :warn-on-boxed)

(definterface IFib
  (^long fib [^long n]))

(deftype Fibonacci []
  IFib
  (fib [_  n]
    (if (or (zero? n)
            (== 1 n))
      (long n)
      (long (+ (.fib _ (- n 1))
               (.fib _ (- n 2)))))))

(def ^:private ^Fibonacci fibonacci (Fibonacci.))

(defn benchmark [^long run-ms f]
  (let [t-start (System/currentTimeMillis)
        t-stop (+ t-start (long (* run-ms)))
        rs (reduce (fn [results i]
                     (let [result (f)
                           t (System/currentTimeMillis)]
                       (if (< t t-stop)
                         (conj results [i t result])
                         (reduced (conj results [i t result])))))
                   []
                   (range))
        [^long i ^long t result] (last rs)
        elapsed-time (- t t-start)
        mean-time (/ elapsed-time i)]
    [result (+ i 1) mean-time]))

(defn- fib-sum [^long n]
  (let [r (loop [i 1
                 sum 0]
            (if (< i n)
              (recur (inc i) (+ sum (long (.fib fibonacci i))))
              sum))]
    r))

(defn -main [& args]
  (let [run-ms (parse-long (first args))
        n (parse-long (second args))
        _ (benchmark run-ms #(fib-sum n))
        [result count mean-time] (benchmark run-ms #(fib-sum n))]
    (println (str count ";" (double mean-time) ";" result))))

(comment
  (-main "10000" "36")
  :rcf)

