require "./fib.cr"
require "../../lib/crystal/benchmark.cr"

run_t = ARGV[0].to_i
warmup_t = ARGV[1].to_i
input = ARGV[2].to_i

bench(input, warmup_t) {|n| fibonacci(n)}

bench(input, run_t) {|n| fibonacci(n)}