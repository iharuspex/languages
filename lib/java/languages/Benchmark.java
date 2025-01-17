package languages;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Supplier;

public class Benchmark {
  public record BenchmarkResult<T>(
      double meanMs,
      double stdDevMs,
      double minMs,
      double maxMs,
      int runs,
      T result) {
    public <R> BenchmarkResult<R> withResult(R newResult) {
      return new BenchmarkResult<>(meanMs, stdDevMs, minMs, maxMs, runs, newResult);
    }
  }

  private record TimedResult<T>(long totalElapsedTime, long elapsedTime, T result) {
  }

  private static class Stats {
    final double meanMs;
    final double stdDevMs;
    final double minMs;
    final double maxMs;
    final int runs;

    Stats(long totalElapsedTime, List<Long> elapsedTimes) {
      this.runs = elapsedTimes.size();
      this.meanMs = elapsedTimes.stream()
          .mapToDouble(t -> t / 1_000_000.0)
          .average()
          .orElse(0.0);

      double variance = elapsedTimes.stream()
          .mapToDouble(t -> t / 1_000_000.0)
          .map(t -> t - meanMs)
          .map(d -> d * d)
          .average()
          .orElse(0.0);

      this.stdDevMs = Math.sqrt(variance);
      this.minMs = elapsedTimes.stream()
          .mapToDouble(t -> t / 1_000_000.0)
          .min()
          .orElse(0.0);
      this.maxMs = elapsedTimes.stream()
          .mapToDouble(t -> t / 1_000_000.0)
          .max()
          .orElse(0.0);
    }
  }

  public static <T> BenchmarkResult<T> run(Supplier<T> f, long runMs) {
    long runNs = runMs * 1_000_000;
    List<TimedResult<T>> results = new ArrayList<>();
    long totalElapsedTime = 0;

    while (totalElapsedTime < runNs) {
      long t0 = System.nanoTime();
      T result = f.get();
      long t1 = System.nanoTime();
      long elapsedTime = t1 - t0;
      totalElapsedTime += elapsedTime;
      results.add(new TimedResult<>(totalElapsedTime, elapsedTime, result));
    }

    TimedResult<T> lastResult = results.get(results.size() - 1);
    List<Long> elapsedTimes = results.stream()
        .map(r -> r.elapsedTime)
        .toList();

    Stats stats = new Stats(lastResult.totalElapsedTime, elapsedTimes);
    return new BenchmarkResult<>(
        stats.meanMs,
        stats.stdDevMs,
        stats.minMs,
        stats.maxMs,
        stats.runs,
        lastResult.result);
  }

  public static String formatResults(BenchmarkResult<?> result) {
    return String.format("%.6f,%.6f,%.6f,%.6f,%d,%s",
        result.meanMs,
        result.stdDevMs,
        result.minMs,
        result.maxMs,
        result.runs,
        result.result);
  }
}
