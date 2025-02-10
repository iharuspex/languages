#!/usr/bin/env julia
# peek-asm.jl

using InteractiveUtils

include("fibonacci.jl")
include("../../lib/julia/benchmark.jl")
using .Fibonacci
using .Benchmark

function main()
    if length(ARGS) < 1
        println("Usage: julia peek-asm.jl <n>")
        exit(1)
    end

    n = parse(Int, ARGS[1])

    # Warmup run
    Benchmark.run(() -> Fibonacci.fibonacci(n), 1000)

    @code_native Fibonacci.fibonacci(Val(n))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
