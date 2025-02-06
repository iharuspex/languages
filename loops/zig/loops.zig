const std = @import("std");

const rand = std.crypto.random;

pub fn loops(comptime iterations_outer: u32, comptime iterations_inner: u32, divisor: u32) u32 {
    // get a random number 0 <= r < 10k
    const random = rand.intRangeLessThanBiased(u32, 0, 10_000);

    // array of 10k elements initialized to 0
    var arr = [_]u32{0} ** iterations_outer;

    // 10k outer loop iterations
    // iterate over array itself to prevent permanent bound checks for arr[i]
    for (&arr) |*elem| {
        // 10k inner loop iterations, per outer loop iteration
        for (0..iterations_inner) |j| {
            // simple sum
            elem.* += @as(u32, @truncate(j)) % divisor;
        }

        // add a random value to each element in array
        elem.* += random;
    }

    return arr[random];
}
