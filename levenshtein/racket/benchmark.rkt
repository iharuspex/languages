#lang racket
(require racket/hash)

(provide run format-results)

;; A helper to get a (rough) nanosecond reading.
;; (Note: Racket doesn’t have a built-in monotonic nanoTime,
;; so we use current-inexact-milliseconds multiplied up.)
(define (current-nanotime)
  (inexact->exact (round (* (current-inexact-milliseconds) 1000000))))

;; run : (-> any) number -> hash
;;
;; f is the function to run repeatedly.
;; run-ms is the total run time in milliseconds.
;;
;; Special cases:
;;   * run-ms = 0 => don’t run, just return a “dummy” result.
;;   * run-ms = 1 => don’t print status dots (assumed to be a correctness check).
;;
;; Returns a hash with keys:
;;   'runs, 'result, 'mean-ms, 'min-ms, 'max-ms, 'std-dev-ms
(define (run f run-ms)
  (if (= run-ms 0)
      (hash 'runs 0
            'result (f)
            'mean-ms 0
            'min-ms 0
            'max-ms 0
            'std-dev-ms 0)
      (let* ([run-ns (* run-ms 1000000)] ; convert run-ms (milliseconds) to nanoseconds
             [init-t (current-nanotime)]
             [last-status-t init-t])
        (when (> run-ms 1)
          (display ".") (flush-output))
        (define (loop last-tet results last-status-t)
          (let* ([t0 (current-nanotime)]
                 [result (f)]
                 [t1 (current-nanotime)]
                 [elapsed-time (- t1 t0)]
                 [total-elapsed-time (+ last-tet elapsed-time)]
                 [timed-result (list total-elapsed-time elapsed-time result)]
                 [print-status? (and (> run-ms 1)
                                     (> (- t0 last-status-t) 1000000000))])
            (when print-status?
              (display ".") (flush-output))
            (if (< total-elapsed-time run-ns)
                (loop total-elapsed-time
                      (cons timed-result results)
                      (if print-status? t1 last-status-t))
                (reverse (cons timed-result results)))))
        (let* ([final-results (loop 0 '() last-status-t)]
               ;; Get the final timed result (i.e. from the last run)
               [last-run (car (reverse final-results))]
               [total-elapsed-time (first last-run)]
               [result (list-ref last-run 2)]
               [elapsed-times (map second final-results)]
               [runs (length final-results)]
               [mean-ns (/ total-elapsed-time runs)]
               [min-ns (apply min elapsed-times)]
               [max-ns (apply max elapsed-times)]
               [variance (/ (apply + (map (λ (t)
                                            (expt (- t mean-ns) 2))
                                          elapsed-times))
                            runs)]
               [std-dev-ns (sqrt variance)]
               [mean-ms (/ mean-ns 1000000.0)]
               [min-ms (/ min-ns 1000000.0)]
               [max-ms (/ max-ns 1000000.0)]
               [std-dev-ms (/ std-dev-ns 1000000.0)])
          (when (> run-ms 1)
            (newline))
          (hash 'runs runs
                'result result
                'mean-ms mean-ms
                'min-ms min-ms
                'max-ms max-ms
                'std-dev-ms std-dev-ms)))))

;; format-results : hash -> string
;; Formats the benchmark results as:
;;   mean-ms,std-dev-ms,min-ms,max-ms,runs,result
(define (format-results stats)
  (format "~a,~a,~a,~a,~a,~a"
          (hash-ref stats 'mean-ms)
          (hash-ref stats 'std-dev-ms)
          (hash-ref stats 'min-ms)
          (hash-ref stats 'max-ms)
          (hash-ref stats 'runs)
          (hash-ref stats 'result)))
