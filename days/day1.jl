#!/usr/bin/env julia

function parsenotes(text)
    [(t=='L' ? -1 : 1, parse(Int, s))
        for (t,s...) in split(text)]
end


function part1(data)
    rs = parsenotes(data)
    p, res = 50, 0
    for (d, n) in rs
        p = (p + n*d) % 100
        res += p == 0
    end
    return res
end


function part2(data)
    rs = parsenotes(data)
    p, res = 50, 0
    for (d, n) in rs
        for i in 1:n
            p = (p + d) % 100
            res += p == 0
        end
    end
    return res
end


function @main(args)
    data = raw"
    L68
    L30
    R48
    L5
    R60
    L55
    L1
    L99
    R14
    L82
    "
    @assert part1(data) == 3
    @assert part2(data) == 6

    fn = isempty(args) ? "day1.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
