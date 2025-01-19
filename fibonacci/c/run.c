/**
 * @file
 * @brief This file uses Google style formatting.
 */

#include "benchmark.h"
#include "stdint.h"
#include "stdio.h"
#include "stdlib.h"

int32_t fibonacci(int32_t n) {
  if (n == 0) return 0;
  if (n == 1) return 1;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

static int32_t fib_sum(int32_t n) {
  int32_t sum = 0;
  for (int32_t i = 1; i < n; i++) {
    sum += fibonacci(i);
  }
  return sum;
}

// The work function that benchmark will time
static benchmark_result_t work(void* data) {
  int* n = (int*)data;
  int r = fib_sum(*n);
  benchmark_result_t result = {.value.number = r};
  return result;
}

int main(int argc, char** argv) {
  int run_ms = atoi(argv[1]);
  int u = atoi(argv[2]);
  // Warmup
  benchmark_run(work, &u, run_ms);
  // Actual benchmark
  benchmark_stats_t stats = benchmark_run(work, &u, run_ms);
  char buffer[1024];
  benchmark_format_results(stats, buffer, sizeof(buffer));
  printf("%s\n", buffer);
}
