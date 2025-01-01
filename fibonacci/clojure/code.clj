(ns code
  (:gen-class))

(set! *unchecked-math* :warn-on-boxed)

(definterface IFib
  (^long fib [^long n]))

(deftype Fibonacci []
  IFib
  (fib [_ n]
    (if (<= n 1)
      n
      (+ (.fib _ (- n 1))
         (.fib _ (- n 2))))))

(def ^:private ^Fibonacci fibonacci (Fibonacci.))

(defn -main [& args]
  (let [u (long (parse-long (first args)))
        r (loop [i 1
                 sum 0]
            (if (< i u)
              (recur (inc i) (+ sum (long (.fib fibonacci i))))
              sum))]
    (println r)))
