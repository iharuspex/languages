#lang racket

(require racket/require
         "levenshtein.rkt"
         (for-syntax racket/base) ;; filtered-in fails without this
         (only-in racket/fixnum
                  make-fxvector
                  for/fxvector)
         (filtered-in
          (λ (name)
            (and (regexp-match #rx"^unsafe-fx" name)
                 (regexp-replace #rx"unsafe-" name "")))
          racket/unsafe/ops)
         racket/cmdline
         racket/list
         racket/match
         racket/file)

(command-line
  #:args args

  (define run-ms (string->number (list-ref args 0)))
  (define warmup-ms (string->number (list-ref args 1)))
  (define words (file->lines (list-ref args 2)))

  (define distances (levenshtein-distances words))
  (define total-distance (apply + distances))
  (printf "Total Levenshtein distance: ~a\n" total-distance))