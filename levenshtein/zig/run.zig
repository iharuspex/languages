const std = @import("std");
const Allocator = std.mem.Allocator;

const benchmark = @import("benchmark");
const levenshteinDistance = @import("./levenshtein.zig").levenshteinDistance;

fn calculateDistances(allocator: Allocator, word_list: *const std.ArrayList([]const u8), buffer: *const []usize) !std.ArrayList(usize) {
    var results = try std.ArrayList(usize).initCapacity(allocator, (word_list.items.len * (word_list.items.len - 1)) / 2);

    const second_last_index = word_list.items.len - 1;

    for (word_list.items[0..second_last_index], 0..second_last_index) |wordA, i| {
        // rest of words in list for comparison
        const cmp_words = word_list.items[(i + 1)..];

        for (cmp_words, 0..cmp_words.len) |wordB, _| {
            const distance = levenshteinDistance(&wordA, &wordB, buffer);
            try results.append(distance);
        }
    }

    return results;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // retrieve arguments for benchmark, contains program arguments
    const args = try benchmark.loadArguments(allocator);

    // parse program arguments
    const word_list = try benchmark.fileReadLines(allocator, args.program_args[0]);

    // calculate length of longest input string
    var max_inp_len: usize = 0;

    for (word_list.items) |word| {
        max_inp_len = @max(max_inp_len, word.len);
    }

    // reuse buffer for prev_row and curr_row to minimize allocations
    const buffer = try allocator.alloc(usize, (max_inp_len + 1) * 2);

    // perform full benchmark
    const context = benchmark.createContext(calculateDistances);
    const stats = (try context.benchmark(allocator, args.warmup_ms, args.run_ms, .{ allocator, &word_list, &buffer })).?;

    // get last result for success checks
    const last_result = stats.lastResult();

    // sum the distances outside the benchmarked function
    var sum: usize = 0;

    for ((try last_result).items) |distance| {
        sum += distance;
    }

    // output results
    try stats.printOutput(allocator, sum);
}
