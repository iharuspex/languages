module Loops

export loops

function loops(u::Int)::Int
    a = zeros(Int,10^4)
    r = rand(1:10^4)
    @inbounds for i ∈ 1:10^4
        @inbounds for j ∈ 1:10^4
            a[i] = a[i] + j%u
        end
        a[i] = a[i] + r
    end
    return a[r]
end

end # module Loops