const std = @import("std");

const levenshteinDistance = @import("./levenshtein.zig").levenshteinDistance;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args_cli = try std.process.argsAlloc(allocator);

    if (args_cli.len < 3) {
        const stderr = std.io.getStdErr().writer();
        try stderr.writeAll("Please provide at least two strings as arguments.\n");
        std.process.exit(1);
    }

    const args = args_cli[1..];

    // calculate length of longest input string
    var max_inp_len: usize = 0;

    for (args) |argument| {
        max_inp_len = @max(max_inp_len, argument.len);
    }

    // reuse prev and curr row to minimize allocations
    // try different integer sizes (u32/u64/u128/usize) to see their impact on performance
    const buffer = try allocator.alloc(u32, (max_inp_len + 1) * 2);

    var min_distance: usize = std.math.maxInt(usize);
    var times: usize = 0;

    const fn_levenshtein = levenshteinDistance(@typeInfo(@TypeOf(buffer)).Pointer.child);

    // compare all pairs of strings
    for (args, 0..args.len) |argA, i| {
        for (args, 0..args.len) |argB, j| {
            if (i == j) {
                continue;
            }

            const distance = fn_levenshtein(&argA, &argB, &buffer);
            min_distance = @min(min_distance, distance);

            times += 1;
        }
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("times: {d}\n", .{times});
    try stdout.print("min_distance: {d}\n", .{min_distance});
}
