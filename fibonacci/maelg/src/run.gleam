import benchmark
import fibonacci
import gleam/int
import gleam/io
import gleam/result

pub fn main(args: List(String)) -> Int {
  case args {
    [run_ms_str, warmup_ms_str, n_str] -> {
      let run_ms = int.base_parse(run_ms_str, 10) |> result.unwrap(0)
      let warmup_ms = int.base_parse(warmup_ms_str, 10) |> result.unwrap(0)
      let n = int.base_parse(n_str, 10) |> result.unwrap(0)

      // Warmup run (results discarded)
      let _warmup = benchmark.run(fn() { fibonacci.fibonacci(n) }, warmup_ms)

      // Benchmark run
      let result = benchmark.run(fn() { fibonacci.fibonacci(n) }, run_ms)
      io.println(benchmark.format_results(result))
      0
    }

    _ -> {
      io.println("Usage: run <run_ms> <warmup_ms> <n>")
      1
    }
  }
}
