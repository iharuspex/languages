# Fibonacci

This program should benchmark a function computing `fibonacci(n)` using naïve recursion.
* The code is supposed to have early return for `n < 2` (the base cases).
* For the non-base cases the code should do two recursive calls.
* The code should be free of any hints to the compiler to memoize, use tail recursion,
  iterative methods, or any avoidance of the naïve recursion.

If some compiler finds ways to avoid recursive calls without any hints, than that is a result. We are in some sense testing compilers here, after all.

Reference implementations:
* Clojure: [run.clj](clojure/run.clj)
* Java: [run.java](jvm/run.java)
* C: [run.c](c/run.c)

## Legacy

This program computes the sum of the first N fibonacci numbers.
Each fibonacci number is computed using a naive recursive solution.
Submissions using faster tail-recursion or iterative solutions will not not be accepted.
Emphasizes function call overhead, stack pushing / popping, and recursion.

Below is the reference C program.
All languages must do the equivalent amount of work and meet these requirements:

```C
#include "stdio.h"
#include "stdlib.h"
#include "stdint.h"
                                           // ALL IMPLEMENTAITONS MUST...
int32_t fibonacci(int32_t n) {             // Have a function that recursively compute a fibonacci number with this naive algorithm
  if (n == 0) return 0;                    // Base case for input 0
  if (n == 1) return 1;                    // Base case for input 1
  return fibonacci(n-1) + fibonacci(n-2);  // Must make two recursive calls for each non-base invocation
}                                          // No result caching, conversion to tail recursion, or iterative solutions.

int main (int argc, char** argv) {
  int32_t u = atoi(argv[1]);               // Get exactly one numberic value from the command line
  int32_t r = 0;                           // Create variable to store sum
  for (int32_t i = 1; i < u; i++) {        // Loop 1...u times
    r += fibonacci(i);                     // Sum all fibonacci numbers 1...u
  }
  printf("%d\n", r);                       // Print out the single, numeric sum
}
```
