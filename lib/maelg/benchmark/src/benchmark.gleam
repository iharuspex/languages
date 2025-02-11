// benchmark.gleam

import gleam/erlang
import gleam/int
import gleam/string

pub type BenchmarkResult(a) {
  BenchmarkResult(run_count: Int, total_time_ns: Int, last_result: a)
}

pub fn run(a: fn() -> a, run_ms: Int) -> BenchmarkResult(a) {
  let run_ns = run_ms * 1_000_000
  let start = erlang.system_time(erlang.Nanosecond)
  run_loop(a, run_ns, 0, start, a())
}

fn run_loop(
  a: fn() -> a,
  run_ns: Int,
  count: Int,
  start: Int,
  last: a,
) -> BenchmarkResult(a) {
  let now = erlang.system_time(erlang.Nanosecond)
  let elapsed = now - start
  case elapsed < run_ns {
    True -> {
      let result = a()
      run_loop(a, run_ns, count + 1, start, result)
    }
    False -> BenchmarkResult(count, elapsed, last)
  }
}

pub fn format_results(result: BenchmarkResult(Int)) -> String {
  string.concat([
    int.to_string(result.run_count),
    ",",
    int.to_string(result.total_time_ns),
    ",",
    int.to_string(result.last_result),
  ])
}
