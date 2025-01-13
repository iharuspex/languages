use std::env;

/// Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
/// Space Complexity: O(min(m,n)) - only uses two rows instead of full matrix
/// Time Complexity: O(m*n) where m and n are the lengths of the input strings
fn levenshtein_distance(s1: &[u8], s2: &[u8]) -> usize {
    let (s1_bytes, s2_bytes) = if s1.len() > s2.len() {
        (s2, s1)
    } else {
        (s1, s2)
    };

    let m = s1_bytes.len();
    let n = s2_bytes.len();

    // Use two rows instead of full matrix for space optimization
    let mut prev_row = vec![0; m + 1];
    let mut curr_row = vec![0; m + 1];

    // Main computation loop
    for j in 1..=n {
        curr_row[0] = j;

        for i in 1..=m {
            let cost = if s1_bytes[i - 1] == s2_bytes[j - 1] {
                0
            } else {
                1
            };

            // Calculate minimum of three operations
            curr_row[i] = std::cmp::min(
                std::cmp::min(
                    prev_row[i] + 1,     // deletion
                    curr_row[i - 1] + 1, // insertion
                ),
                prev_row[i - 1] + cost, // substitution
            );
        }

        // Swap rows
        std::mem::swap(&mut prev_row, &mut curr_row);
    }

    prev_row[m]
}

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.len() < 2 {
        println!("Please provide at least two strings as arguments.");
        return;
    }

    let mut min_distance = None;
    let mut times = 0;

    // Compare all pairs of strings
    for i in 0..args.len() {
        for j in 0..args.len() {
            if i != j {
                let distance = levenshtein_distance(args[i].as_bytes(), args[j].as_bytes());
                if let Some(current_min) = min_distance {
                    if distance < current_min {
                        min_distance = Some(distance);
                    }
                } else {
                    min_distance = Some(distance);
                }
                times += 1;
            }
        }
    }

    println!("times: {}", times);
    println!("min_distance: {}", min_distance.unwrap_or(usize::MAX));
}
