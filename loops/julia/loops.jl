module Loops

export loops

function loops(u::Int)::Int
    a = zeros(Int, 10^4)
    r = rand(1:10^4)
    @inbounds for i in 1:10^4
        local sum = 0
        @inbounds @simd for j in 1:10^4
            sum += j % u
        end
        a[i] += sum + r
    end
    return a[r]
end

end # module Loops