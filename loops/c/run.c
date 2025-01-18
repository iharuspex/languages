#include "stdio.h"
#include "stdlib.h"
#include "stdint.h"
#include "time.h"

#include "benchmark.h"


int loops(int u) {
  srand(time(NULL));                   // FIX random seed
  int r = rand() % 10000;              // Get a random integer 0 <= r < 10k
  int32_t a[10000] = {0};              // Array of 10k elements initialized to 0
  for (int i = 0; i < 10000; i++) {    // 10k outer loop iterations
    for (int j = 0; j < 10000; j++) {  // 10k inner loop iterations, per outer loop iteration
      a[i] = a[i] + j%u;               // Simple sum
    }
    a[i] += r;                         // Add a random value to each element in array
  }
  return a[r];
}

// The work function that benchmark will time
static benchmark_result_t work(void* data) {
  int* u = (int*)data;
  int r = loops(*u);
  benchmark_result_t result = {.value.number = r};
  return result;
}


int main (int argc, char** argv) {
  int run_ms = atoi(argv[1]);
  int u = atoi(argv[2]);
  // Warmup
  benchmark_run(work, &u, run_ms);
  // Actual benchmark
  benchmark_stats_t stats = benchmark_run(work, &u, run_ms);
  printf("%.6f,%.6f,%.6f,%.6f,%d,%ld\n", stats.mean_ms, stats.std_dev_ms,
         stats.min_ms, stats.max_ms, stats.runs, stats.last_result.value);
}
