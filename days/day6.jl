#!/usr/bin/env julia

function part1(data)
    lines = split(data, '\n', keepempty=false)
    ops = split(lines[end])
    xs = stack(parse.(Int, split(s)) for s in lines[1:end-1])
    sum(zip(ops, eachrow(xs))) do (f, r)
        f == "+" ? sum(r) : prod(r)
    end
end


function part2(data)
    lines = split(data, '\n', keepempty=false)
    w = length.(lines) |> maximum
    s = stack(rpad.(lines, w), dims=1)
    res = 0
    xs = Int[]
    for i in size(s,2):-1:1
        r = s[:,i]
        x = filter(∈('0':'9'), r) .- '0'
        if !isempty(x)
            push!(xs, evalpoly(10, reverse(x)))
        else
            xs = Int[]
        end
        if r[end] == '+'
            res += sum(xs)
        elseif r[end] == '*'
            res += prod(xs)
        end
    end
    return res
end


function @main(args)
    data = raw"""
    123 328  51 64 
     45 64  387 23 
      6 98  215 314
    *   +   *   +  
    """
    @assert part1(data) == 4277556
    @assert part2(data) == 3263827

    fn = isempty(args) ? "day6.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
