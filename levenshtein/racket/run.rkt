#lang racket
(require (file "../../lib/racket/benchmark.rkt")
         "levenshtein.rkt"
         racket/cmdline
         racket/file)

(command-line
  #:args args
  (define run-ms (string->number (list-ref args 0)))
  (define warmup-ms (string->number (list-ref args 1)))
  (define words (file->lines (list-ref args 2)))

  ;; Run a warmup (no status output if warmup-ms = 1)
  (run (λ () (levenshtein-distances words)) warmup-ms)
  ;; Run the benchmark and format the results.
  (define the-results (run (λ () (levenshtein-distances words)) run-ms))
  (define total-distance (for/sum ([distance (in-list (results-result the-results))])
                           distance))
  (printf "~a\n" (format-results (struct-copy results the-results [result total-distance]))))
