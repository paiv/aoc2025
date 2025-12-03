#!/usr/bin/env julia


function parsenotes(text)
    grid = parse.(Int, stack(split(text), dims=1))
end


function part1(data)
    grid = parsenotes(data)
    sum(eachrow(grid)) do r
        i = argmax(r[1:end-1])
        b = maximum(r[i+1:end])
        10r[i]+b
    end
end


function solve(N, data)
    memo = Dict{Any,Union{Int,Nothing}}()
    function inner(r, n=N)
        n == 0 && return 0
        isempty(r) && return
        get!(memo, (n, r)) do
            a = inner(r[1:end-1], n-1)
            b = inner(r[1:end-1], n)
            isnothing(a) && return b
            k = r[end] + 10a
            isnothing(b) && return k
            max(k, b)
        end
    end
    grid = parsenotes(data)
    inner.(eachrow(grid))
end


part1(data) = solve(2, data) |> sum
part2(data) = solve(12, data) |> sum


viz(data, N=12) = viz(stdout, data, N)

function viz(io, data::AbstractString, N::Int=12)
    grid = parsenotes(data)
    rs = solve(N, data)
    for (x,r) in zip(rs, eachrow(grid))
        i = 1
        for d in reverse(digits(x))
            j = findnext(==(d), r, i)
            print(io, join(r[i:j-1]))
            printstyled(io, r[j], color=:green)
            i = j+1
        end
        println(io, join(r[i:end]))
    end
end


function @main(args)
    data = raw"
    987654321111111
    811111111111119
    234234234234278
    818181911112111
    "
    @assert part1(data) == 357
    @assert part2(data) == 3121910778619
    #viz(stderr, data, 12)

    fn = isempty(args) ? "day3.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
