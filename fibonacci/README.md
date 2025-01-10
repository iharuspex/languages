# Fibonacci

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
