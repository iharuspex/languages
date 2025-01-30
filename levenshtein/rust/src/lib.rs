use num::{traits::bounds::UpperBounded, Integer, NumCast, Unsigned};

// Define alias for Trait Bounds until official Trait Aliases are no longer experimental.
// https://github.com/rust-lang/rust/issues/41517
// https://github.com/rust-lang/rfcs/issues/3528#issuecomment-1807738102
// https://github.com/rust-lang/rfcs/pull/1733#issuecomment-243840014
pub trait CostInteger: Unsigned + Integer + NumCast + Copy + UpperBounded + From<bool> {}
impl<T: Unsigned + Integer + NumCast + Copy + UpperBounded + From<bool>> CostInteger for T {}

/// Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm.
///
/// Space Complexity: O(min(m,n)) - only uses two rows instead of full matrix
/// Time Complexity: O(m*n) - where m and n are the lengths of the input strings
pub fn levenshtein_distance<T: CostInteger>(
    s1: &impl AsRef<str>,
    s2: &impl AsRef<str>,
    buffer: &mut Vec<T>,
) -> T {
    let s1: &str = s1.as_ref();
    let s2: &str = s2.as_ref();

    // correctness checks
    assert!(s1.len().max(s2.len()) < T::max_value().to_usize().expect("max value") / 2);
    assert!(s1.is_ascii() && s2.is_ascii());

    // make s1 the shorter string for space optimization
    let (s1, s2) = if s1.len() > s2.len() {
        (s2.as_bytes(), s1.as_bytes())
    } else {
        (s1.as_bytes(), s2.as_bytes())
    };

    let m = s1.len();

    let row_elements = m + 1;
    let req_size = row_elements * 2;

    if buffer.len() < req_size {
        buffer.extend((buffer.len()..req_size).map(|_| T::zero()));
    }

    // use two rows instead of full matrix for space optimization
    let (mut prev_row, mut curr_row) = buffer[0..req_size].split_at_mut(row_elements);

    // Initialize the previous row
    for (i, v) in prev_row.iter_mut().enumerate() {
        *v = <T as num::NumCast>::from(i).expect("init number");
    }

    // main computation loop
    for (j, ch2) in s2.iter().enumerate() {
        curr_row[0] = <T as num::NumCast>::from(j + 1).expect("first element");

        for (i, ch1) in s1.iter().enumerate() {
            let cost: T = (ch1 != ch2).into();

            // calculate minimum of three operations
            curr_row[i + 1] = (prev_row[i + 1] + T::one()) // deletion
                .min(curr_row[i] + T::one()) // insertion
                .min(prev_row[i] + cost); // substitution
        }

        // swap rows
        // (prev_row, curr_row) = (curr_row, prev_row);
        std::mem::swap(&mut prev_row, &mut curr_row);
    }

    *prev_row.last().expect("last element")
}
