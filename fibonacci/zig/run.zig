const std = @import("std");

const benchmark = @import("benchmark");
const fibonacci = @import("./fibonacci.zig").fibonacci;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // retrieve arguments for benchmark, contains program arguments
    const args = try benchmark.loadArguments(allocator);

    // parse program arguments
    const number: usize = try std.fmt.parseInt(usize, args.program_args[0], 0);

    // perform full benchmark
    const context = benchmark.createContext(fibonacci);
    const stats = (try context.benchmark(allocator, args.warmup_ms, args.run_ms, .{number})).?;

    // get last result for success checks
    const last_result = stats.lastResult();

    // output results
    try stats.printOutput(allocator, last_result);
}
