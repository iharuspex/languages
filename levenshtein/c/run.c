/**
 * @file
 * @brief This file uses Google style formatting.
 */

/**
 * This program implements the Levenshtein distance algorithm and provides
 * functionality to benchmark it with the following features:
 * - Reads words from an input file
 * - Calculates Levenshtein distances between all unique pairs
 * - Returns sum of all distances as final result
 * - Provides benchmark statistics in CSV format
 *
 * The program takes two command line arguments:
 * 1. run_ms: How long to run the benchmark in milliseconds
 * 2. input_file: Path to file containing space-separated words
 *
 * Output format: mean_ms,std_dev_ms,min_ms,max_ms,runs,result
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "benchmark.h"

static char** read_words(const char* filename, int* word_count) {
  // First read entire file content
  FILE* file = fopen(filename, "r");
  if (!file) {
    fprintf(stderr, "Could not open file: %s\n", filename);
    exit(1);
  }

  // Get file size
  fseek(file, 0, SEEK_END);
  long file_size = ftell(file);
  fseek(file, 0, SEEK_SET);

  // Read entire file into buffer
  char* content = malloc(file_size + 1);
  fread(content, 1, file_size, file);
  content[file_size] = '\0';
  fclose(file);

  // Count words (space separated)
  int capacity = 100;
  char** words = malloc(capacity * sizeof(char*));
  *word_count = 0;

  // Split on whitespace
  char* word = strtok(content, " \n\t\r");
  while (word != NULL) {
    if (*word_count == capacity) {
      capacity *= 2;
      words = realloc(words, capacity * sizeof(char*));
    }
    words[*word_count] = strdup(word);
    (*word_count)++;
    word = strtok(NULL, " \n\t\r");
  }

  free(content);
  return words;
}

// Can either define your own min function
// or use a language / standard library function
int min(int a, int b, int c) {
  int min = a;
  if (b < min) min = b;
  if (c < min) min = c;
  return min;
}

/**
 * Calculates the Levenshtein distance between two strings using an optimized
 * version of Wagner-Fischer algorithm that uses O(min(m,n)) space.
 *
 * @param s1 The first string to compare
 * @param s2 The second string to compare
 * @return The Levenshtein distance between s1 and s2
 */

int levenshtein_distance(const char* s1, const char* s2) {
  // Get lengths of both strings
  int mt = strlen(s1);
  int nt = strlen(s2);
  // Assign shorter one to str1, longer one to str2
  const char* str1 = mt <= nt ? s1 : s2;
  const char* str2 = mt <= nt ? s2 : s1;
  // store the lengths of shorter in m, longer in n
  int m = str1 == s1 ? mt : nt;
  int n = str1 == s1 ? nt : mt;

  // Create two rows, previous and current
  int prev[m + 1];
  int curr[m + 1];

  // initialize the previous row
  for (int i = 0; i <= m; i++) {
    prev[i] = i;
  }

  // Iterate and compute distance
  for (int i = 1; i <= n; i++) {
    curr[0] = i;
    for (int j = 1; j <= m; j++) {
      int cost = (str1[j - 1] == str2[i - 1]) ? 0 : 1;
      curr[j] = min(prev[j] + 1,        // Deletion
                    curr[j - 1] + 1,    // Insertion
                    prev[j - 1] + cost  // Substitution
      );
    }
    for (int j = 0; j <= m; j++) {
      prev[j] = curr[j];
    }
  }

  // Return final distance, stored in prev[m]
  return prev[m];
}

typedef struct {
  long* distances;
  int count;
} distances_result_t;

static distances_result_t* calculate_distances(char** words, int word_count) {
  distances_result_t* result = malloc(sizeof(distances_result_t));
  result->count = (word_count * (word_count - 1)) / 2;
  result->distances = malloc(result->count * sizeof(long));
  int idx = 0;

  for (int i = 0; i < word_count; i++) {
    for (int j = i + 1; j < word_count; j++) {
      result->distances[idx++] = levenshtein_distance(words[i], words[j]);
    }
  }
  return result;
}

typedef struct {
  char** words;
  int count;
} word_data_t;

// The work function that benchmark will time
static benchmark_result_t work(void* data) {
  word_data_t* word_data = (word_data_t*)data;
  distances_result_t* distances =
      calculate_distances(word_data->words, word_data->count);
  benchmark_result_t result = {.value.ptr = distances};
  return result;
}

int main(int argc, char* argv[]) {
  if (argc != 3) {
    fprintf(stderr, "Usage: %s <run_ms> <input_file>\n", argv[0]);
    return 1;
  }

  int run_ms = atoi(argv[1]);
  int word_count;
  char** words = read_words(argv[2], &word_count);

  word_data_t data = {words, word_count};

  // Warmup
  benchmark_stats_t warmup = benchmark_run(work, &data, run_ms);
  distances_result_t* warmup_distances =
      (distances_result_t*)warmup.last_result.value.ptr;
  free(warmup_distances->distances);
  free(warmup_distances);

  // Actual benchmark
  benchmark_stats_t stats = benchmark_run(work, &data, run_ms);

  // Sum the distances outside the benchmarked function
  distances_result_t* distances =
      (distances_result_t*)stats.last_result.value.ptr;

  long sum = 0;
  for (int i = 0; i < distances->count; i++) {
    sum += distances->distances[i];
  }

  stats.last_result.value.number = sum;

  char buffer[1024];
  benchmark_format_results(stats, buffer, sizeof(buffer));
  printf("%s\n", buffer);

  // Clean up everything
  free(distances->distances);
  free(distances);
  for (int i = 0; i < word_count; i++) {
    free(words[i]);
  }
  free(words);

  return 0;
}
