#lang racket

(provide run format-results)

;; Results across processes are not comparable!
(define (current-monotonic-nanotime)
  (inexact->exact (round (* (current-inexact-monotonic-milliseconds) 1000000))))

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
  (cond
    [(zero? run-ms)
     (hash 'runs 0
           'result (f)
           'mean-ms 0
           'min-ms 0
           'max-ms 0
           'std-dev-ms 0)]
    [else
     ; convert run-ms (milliseconds) to nanoseconds
     (define run-ns (* run-ms 1000000))
     (define init-t (current-monotonic-nanotime))
     (define last-status-t init-t)
     (when (> run-ms 1)
       (display "." (current-error-port))
       (flush-output (current-error-port)))
     (define final-results
       (let loop ([last-tet 0]
                  [results '()]
                  [last-status-t last-status-t])
         (define t0 (current-monotonic-nanotime))
         (define result (f))
         (define t1 (current-monotonic-nanotime))
         (define elapsed-time (- t1 t0))
         (define total-elapsed-time (+ last-tet elapsed-time))
         (define timed-result (list total-elapsed-time elapsed-time result))
         (define print-status? (and (> run-ms 1)
                                    (> (- t0 last-status-t) 1000000000)))
         (when print-status?
           (display "." (current-error-port))
           (flush-output (current-error-port)))
         (if (< total-elapsed-time run-ns)
             (loop total-elapsed-time
                   (cons timed-result results)
                   (if print-status? t1 last-status-t))
             (reverse (cons timed-result results)))))
     ;; Get the final timed result (i.e. from the last run)
     (define last-run (last final-results))
     (define total-elapsed-time (first last-run))
     (define result (third last-run))
     (define elapsed-times (map second final-results))
     (define runs (length final-results))
     (define mean-ns (/ total-elapsed-time runs))
     (define min-ns (apply min elapsed-times))
     (define max-ns (apply max elapsed-times))
     (define variance (/ (apply + (map (λ (t)
                                         (expt (- t mean-ns) 2))
                                       elapsed-times))
                         runs))
     (define std-dev-ns (sqrt variance))
     (define mean-ms (/ mean-ns 1000000.0))
     (define min-ms (/ min-ns 1000000.0))
     (define max-ms (/ max-ns 1000000.0))
     (define std-dev-ms (/ std-dev-ns 1000000.0))
     (when (> run-ms 1)
       (newline (current-error-port)))
     (hash 'runs runs
           'result result
           'mean-ms mean-ms
           'min-ms min-ms
           'max-ms max-ms
           'std-dev-ms std-dev-ms)]))

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
