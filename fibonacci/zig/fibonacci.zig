pub fn fibonacci(n: usize) usize {
    return switch (n) {
        0...1 => n,
        else => fibonacci(n - 1) + fibonacci(n - 2),
    };
}
