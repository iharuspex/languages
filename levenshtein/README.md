# Levenshtein

This program aims to benchmark implementations of a function for [levenshtein distances](https://en.wikipedia.org/wiki/Levenshtein_distance). All implementations must use the [Wagner-Fischer algorithm](https://en.wikipedia.org/wiki/Wagner%E2%80%93Fischer_algorithm), with a few of the performance enhancements:

- Reduced space complexity from O(m*n) to O(min(m,n)) by using only two rows instead of building full matrix
- Always use the shorter string for column dimension to minimize space usage
- Reuse arrays instead of creating new ones

The function should not use pre-allocated memory.

The function will be tested on collection of different length strings (with mostly random geneerated content). To satisfy the correctness test, programs should implement and benchmark a function that takes a sequence of strings as input and returns a sequence of all distances between any pairing of the words. The program should then, outside the measured time, sum these distances and report the sum. The words are provided from a file given as the `input` argument to the program. There is one word per line in the file.

The code should follow the reference implementations as closely as possible:

* Clojure: [run.clj](clojure/run.clj)
* Java: [run.java](jvm/run.java)
* C: [run.c](c/run.c)
