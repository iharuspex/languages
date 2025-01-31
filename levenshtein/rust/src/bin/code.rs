use std::env;

use levenshtein::levenshtein_distance;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.len() < 2 {
        eprintln!("Please provide at least two strings as arguments.");
        std::process::exit(2);
    }

    if args.iter().any(|s| s.is_empty()) {
        eprintln!("This benchmark assumes non-empty strings.");
        std::process::exit(3);
    }

    // calculate length of longest input string
    let mut max_inp_len: usize = 0;

    for argument in args.iter() {
        max_inp_len = max_inp_len.max(argument.len());
    }

    // reuse buffer for prev_row and curr_row to minimize allocations
    // try different integer sizes (u16/u32/u64/usize) to see their impact on performance
    let mut buffer: Vec<u32> = vec![0; (max_inp_len + 1) * 2];

    let mut min_distance = u32::MAX;
    let mut times = 0;

    // compare all pairs of strings
    for (i, s1) in args.iter().enumerate() {
        for (j, s2) in args.iter().enumerate() {
            if i == j {
                continue;
            }

            let distance = levenshtein_distance(s1, s2, &mut buffer);
            min_distance = min_distance.min(distance);

            times += 1;
        }
    }

    println!("times: {times}");
    println!("min_distance: {min_distance}");
}
