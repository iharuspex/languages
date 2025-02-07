#lang racket
(require (file "../../lib/racket/benchmark.rkt")
         "fibonacci.rkt"
         racket/cmdline
         racket/file)

(command-line
  #:args args
  (define run-ms (string->number (list-ref args 0)))
  (define warmup-ms (string->number (list-ref args 1)))
  (define n (string->number (list-ref args 2)))

  ;; Run a warmup (no status output if warmup-ms = 1)
  (run (λ () (fibonacci n)) warmup-ms)
  ;; Run the benchmark and format the results.
  (define results (run (λ () (fibonacci n)) run-ms))
  (printf "~a\n" (format-results results)))
