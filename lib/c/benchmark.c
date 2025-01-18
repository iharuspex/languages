#include "benchmark.h"
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define INITIAL_CAPACITY 1000

typedef struct {
    int64_t total_elapsed;
    int64_t elapsed;
} timed_result_t;

static int64_t get_time_ns() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000000 + ts.tv_nsec;
}

static double calculate_mean(timed_result_t* results, int count) {
    double sum = 0.0;
    for (int i = 0; i < count; i++) {
        sum += results[i].elapsed / 1000000.0;
    }
    return sum / count;
}

static double calculate_std_dev(timed_result_t* results, int count, double mean) {
    double sum_squares = 0.0;
    for (int i = 0; i < count; i++) {
        double diff = (results[i].elapsed / 1000000.0) - mean;
        sum_squares += diff * diff;
    }
    return sqrt(sum_squares / count);
}

benchmark_stats_t benchmark_run(benchmark_fn fn, void* data, int run_ms) {
    int64_t run_ns = (int64_t)run_ms * 1000000;
    int64_t total_elapsed = 0;
    
    timed_result_t* results = malloc(INITIAL_CAPACITY * sizeof(timed_result_t));
    int capacity = INITIAL_CAPACITY;
    int count = 0;
    
    benchmark_result_t last_result;
    
    while (total_elapsed < run_ns) {
        int64_t start = get_time_ns();
        last_result = fn(data);
        int64_t end = get_time_ns();
        int64_t elapsed = end - start;
        total_elapsed += elapsed;
        
        if (count == capacity) {
            capacity *= 2;
            results = realloc(results, capacity * sizeof(timed_result_t));
        }
        
        results[count].total_elapsed = total_elapsed;
        results[count].elapsed = elapsed;
        count++;
    }
    
    double mean = calculate_mean(results, count);
    double std_dev = calculate_std_dev(results, count, mean);
    
    double min_ms = results[0].elapsed / 1000000.0;
    double max_ms = min_ms;
    
    for (int i = 1; i < count; i++) {
        double ms = results[i].elapsed / 1000000.0;
        if (ms < min_ms) min_ms = ms;
        if (ms > max_ms) max_ms = ms;
    }
    
    free(results);
    
    return (benchmark_stats_t) {
        .mean_ms = mean,
        .std_dev_ms = std_dev,
        .min_ms = min_ms,
        .max_ms = max_ms,
        .runs = count,
        .last_result = last_result
    };
}
