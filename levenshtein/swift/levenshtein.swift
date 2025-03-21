/// Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
/// Space Complexity: O(min(m,n)) - only uses two arrays instead of full matrix
/// Time Complexity: O(m*n) where m and n are the lengths of the input strings
func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
    // Early termination checks
    if s1 == s2 { return 0 }
    if s1.isEmpty { return s2.count }
    if s2.isEmpty { return s1.count }

    // Make s1 the shorter string for space optimization
    let (str1, str2) = s1.count > s2.count ? (s2, s1) : (s1, s2)

    // Convert strings to arrays for O(1) access
    let arr1 = str1.utf8CString.dropLast()
    let arr2 = str2.utf8CString.dropLast()

    let m = arr1.count
    let n = arr2.count

    // Use two arrays instead of full matrix for space optimization
    var prevRow = [Int](0...m)
    var currRow = [Int](repeating: 0, count: m + 1)

    // Main computation loop
    for j in 1...n {
        currRow[0] = j

        for i in 1...m {
            let cost = arr1[i-1] == arr2[j-1] ? 0 : 1

            // Calculate minimum of three operations
            currRow[i] = min(
                prevRow[i] + 1,        // deletion
                currRow[i-1] + 1,      // insertion
                prevRow[i-1] + cost    // substitution
            )
        }

        // Swap rows
        (prevRow, currRow) = (currRow, prevRow)
    }

    return prevRow[m]
}

// New function to compute distances for unique string pairs
public func distances(_ words: [String]) -> [Int] {
    var result: [Int] = []
    for i in 0..<words.count {
        for j in (i + 1)..<words.count {
            result.append(levenshteinDistance(words[i], words[j]))
        }
    }
    return result
}
