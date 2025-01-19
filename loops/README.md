# Loops

This program should benchmark a function that makes 100 milion updates to an array,
with some super simple math in each iteration. The code is designed to try force
the compiler to generate code that actually makes 100 million updates. The code
should be free of any hints to the compiler that the loops actually can be fully 
unrolled. If some compiler or interpreter still finds ways to unroll the loops, 
then that will be considered a valid result. 

The code should follow the reference implementations as closely as possible:

* Clojure: [run.clj](clojure/run.clj)
* Java: [run.java](jvm/run.java)
* C: [run.c](c/run.c)

## Legacy

A simple, not-super-useful program that does a total of 1 billion loop iterations, with some addition and mod operations for each.
The idea with this is to emphasize loop, conditional, and basic math performance.

Below is the reference C program.
All languages must do the same array work and computations outlined here.

```C
#include "stdio.h"
#include "stdlib.h"
#include "stdint.h"
#include "time.h"

int main (int argc, char** argv) {     // EVERY PROGRAM IN THIS BENCHMARK MUST...
  int u = atoi(argv[1]);               // Get an single input number from the command line
  srand(time(NULL));
  int r = rand() % 10000;              // Get a single random integer 0 <= r < 10k
  int32_t a[10000] = {0};              // Create an array of 10k elements initialized to 0
  for (int i = 0; i < 10000; i++) {    // 10k outer loop iterations with an iteration variable
    for (int j = 0; j < 100000; j++) { // 100k inner loop iterations, per outer loop iteration, with iteration variable
      a[i] = a[i] + j%u;               // For all 1B iterations, must access array element, compute j%u, update array location
    }
    a[i] += r;                         // For all 10k outer iterations, add the random value to each element in array
  }
  printf("%d\n", a[r]);                // Print out a single element from the array
}
```
