use std::env;

/// Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
/// Space Complexity: O(min(m,n)) - only uses two rows instead of full matrix
/// Time Complexity: O(m*n) where m and n are the lengths of the input strings
fn levenshtein_distance(s1: &[u8], s2: &[u8]) -> u32 {
    let (s1_bytes, s2_bytes) = if s1.len() > s2.len() {
        (s2, s1)
    } else {
        (s1, s2)
    };

    let m = s1_bytes.len();

    // Use two rows instead of full matrix for space optimization
    let mut prev_row = vec![0u32; m + 1];
    let mut curr_row = vec![0u32; m + 1];

    // Main computation loop
    for (j, s2) in s2_bytes.iter().copied().enumerate() {
        curr_row[0] = (j + 1) as u32;

        for (i, s1) in s1_bytes.iter().copied().enumerate() {
            let cost = if s1 == s2 { 0 } else { 1 };

            // Calculate minimum of three operations
            curr_row[i + 1] = (prev_row[i + 1] + 1) // deletion
                .min(curr_row[i] + 1) // insertion
                .min(prev_row[i] + cost); // substitution
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
    println!("min_distance: {}", min_distance.unwrap_or(u32::MAX));
}
