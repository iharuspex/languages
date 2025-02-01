require "./leven.cr"
require "../../lib/crystal/benchmark.cr"

run_t = ARGV[0].to_i
warmup_t = ARGV[1].to_i
input = ARGV[2]

strings = File.read_lines(input)

bench(warmup_t, warmup?: true) { levenshtein(strings) }

bench(run_t) { levenshtein(strings) }