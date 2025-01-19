package jvm;

import languages.Benchmark;

public class run {

    private static int fibonacci(int n) {
        if (n < 2) {
            return n;
        }
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
    
    public static void main(String[] args) {
        var runMs = Integer.parseInt(args[0]);
        var n = Integer.parseInt(args[1]);
        var _warmup = Benchmark.run(() -> fibonacci(n), runMs);
        var results = Benchmark.run(() -> fibonacci(n), runMs);
        System.out.println(Benchmark.formatResults(results));
    }
}
