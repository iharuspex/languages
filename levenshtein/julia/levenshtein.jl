module Levenshtein

export levenshtein_distance, distances

# Calculates the Levenshtein distance between two strings using Wagner-Fischer algorithm
# Space Complexity: O(min(m,n)) - only uses two arrays instead of full matrix
# Time Complexity: O(m*n) where m and n are the lengths of the input strings
function levenshtein_distance(
    str1::String,
    str2::String,
    prev_row::Memory{Int32},
    curr_row::Memory{Int32},
)::Int
    # Early termination checks
    str1 == str2 && return 0
    (s1, s2) = (codeunits(str1), codeunits(str2))
    isempty(s1) && return length(s2)
    isempty(s2) && return length(s1)

    # Make s1 the shorter string for space optimization
    if length(s1) > length(s2)
        s1, s2 = s2, s1
    end

    m, n = length(s1), length(s2)

    # Initialize first row
    for i in 0:m
        @inbounds prev_row[i + 1] = i % Int32
    end

    # Main computation loop
    @inbounds for j in 1:n
        curr_row[1] = j % Int32

        for i in 1:m
            cost = s1[i] == s2[j] ? 0 : 1

            # Calculate minimum of three operations
            @inbounds curr_row[i + 1] = min(
                prev_row[i + 1] + 1,    # deletion
                curr_row[i] + 1,        # insertion
                prev_row[i] + cost      # substitution
            ) % Int32
        end

        # Swap rows
        prev_row, curr_row = curr_row, prev_row
    end

    return @inbounds prev_row[m + 1]
end

# distances : Vector{String} -> Vector{Int}
#
# Computes the Levenshtein distance for every unique unordered pair of strings.
# That is, for each pair A, B (with A ≠ B) the distance is computed only once.
# The function reuses two working arrays for performance.
function distances(strings::Vector{String})
    n = length(strings)
    # There are n*(n-1)/2 unique pairs.
    count = n*(n-1) ÷ 2
    dists = Vector{Int}(undef, count)
    # Determine the maximum number of codeunits in any string, and add one.
    size = maximum(length.(codeunits.(strings))) + 1
    v1 = Vector{Int32}(undef, size)
    v2 = Vector{Int32}(undef, size)
    idx = 1
    for i in 1:(n-1)
        for j in (i+1):n
            d = levenshtein_distance(strings[i], strings[j], v1, v2)
            dists[idx] = d
            idx += 1
        end
    end
    return dists
end

end # module Levenshtein
