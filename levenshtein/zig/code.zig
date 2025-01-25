const std = @import("std");

/// Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
/// Space Complexity: O(min(m,n)) - only uses two arrays instead of full matrix
/// Time Complexity: O(m*n) where m and n are the lengths of the input strings
fn levenshteinDistance(s1: *const []const u8, s2: *const []const u8, buffer: *const []usize) usize {
    // Early termination checks
    if (std.mem.eql(u8, s1.*, s2.*)) return 0;
    if (s1.*.len == 0) return s2.*.len;
    if (s2.*.len == 0) return s1.*.len;

    // Make s1 the shorter string for space optimization
    const str1, const str2 = init: {
        if (s1.*.len > s2.*.len) {
            break :init .{ s2.*, s1.* };
        }

        break :init .{ s1.*, s2.* };
    };

    const m = str1.len;
    const n = str2.len;

    var prev_row = buffer.*[0..(m + 1)];
    var curr_row = buffer.*[(m + 1)..];

    // Initialize first row
    for (0..m + 1) |i| {
        prev_row[i] = i;
    }

    // Main computation loop
    for (str2, 0..n) |ch2, j| {
        curr_row[0] = j + 1;

        for (str1, 0..m) |ch1, i| {
            const cost: usize = @intFromBool(ch1 != ch2);

            // Calculate minimum of three operations
            curr_row[i + 1] = @min(
                prev_row[i + 1] + 1, // deletion
                curr_row[i] + 1, // insertion
                prev_row[i] + cost, // substitution
            );
        }

        // Swap rows
        std.mem.swap([]usize, &prev_row, &curr_row);
    }

    return prev_row[m];
}

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

    // Calculate length of longest input string
    var max_inp_len: usize = 0;

    for (args) |argument| {
        max_inp_len = @max(max_inp_len, argument.len);
    }

    // Reuse prev and curr row to minimize allocations
    const buffer = try allocator.alloc(usize, (max_inp_len + 1) * 2);

    var min_distance: usize = std.math.maxInt(usize);
    var times: usize = 0;

    // Compare all pairs of strings
    for (args, 0..args.len) |argA, i| {
        for (args, 0..args.len) |argB, j| {
            if (i == j) {
                continue;
            }

            const distance = levenshteinDistance(&argA, &argB, &buffer);
            min_distance = @min(min_distance, distance);

            times += 1;
        }
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("times: {d}\n", .{times});
    try stdout.print("min_distance: {d}\n", .{min_distance});
}
