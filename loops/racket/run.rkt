#lang racket
(require (file "../../lib/racket/benchmark.rkt")
         "loops.rkt"
         racket/cmdline
         racket/file)

(command-line
  #:args args
  (define run-ms (string->number (list-ref args 0)))
  (define warmup-ms (string->number (list-ref args 1)))
  (define u (string->number (list-ref args 2)))

  ;; Run a warmup (no status output if warmup-ms = 1)
  (run (λ () (loops u)) warmup-ms)
  ;; Run the benchmark and format the results.
  (define results (run (λ () (loops u)) run-ms))
  (printf "~a\n" (format-results results)))
