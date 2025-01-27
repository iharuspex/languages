const std = @import("std");

/// Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
/// Space Complexity: O(min(m,n)) - only uses two arrays instead of full matrix
/// Time Complexity: O(m*n) where m and n are the lengths of the input strings
pub fn levenshteinDistance(s1: *const []const u8, s2: *const []const u8, buffer: *const []usize) usize {
    // Early termination checks
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
