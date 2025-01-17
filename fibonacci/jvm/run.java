package jvm;

import languages.Benchmark;

public class run {

    private static int fibonacci(int n) {
        if (n == 0) {
            return 0;
        }
        if (n == 1) {
            return 1;
        }
        return fibonacci(n - 1) + fibonacci(n - 2);
    }

    private static int fib_sum(int n) {
        var r = 0;
        for (var i = 1; i < n; i++) {
            r += fibonacci(i);
        }
        return r;
    }
    
    public static void main(String[] args) {
        var runMs = Integer.parseInt(args[0]);
        var n = Integer.parseInt(args[1]);
        var _warmup = Benchmark.run(() -> fib_sum(n), runMs);
        var results = Benchmark.run(() -> fib_sum(n), runMs);
        System.out.println(Benchmark.formatResults(results));
    }
}
