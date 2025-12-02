#!/usr/bin/env julia

function parsenotes(text)
    [parse(Int, m[1]):parse(Int,m[2])
        for m in eachmatch(r"(\d+)-(\d+)", text)]
end


function part1(data)
    rs = parsenotes(data)
    xs = Set(parse(Int, "$x$x")
        for n in 1:5 for x in 1:10^n-1)
    mapreduce(r->sum(r ∩ xs), +, rs)
end


function part2(data)
    rs = parsenotes(data)
    xs = Set(parse(Int, repeat("$x", k))
        for n in 1:5 for k in 2:10÷n for x in 1:10^n-1)
    mapreduce(r->sum(r ∩ xs), +, rs)
end


function @main(args)
    data = raw"
    11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
    1698522-1698528,446443-446449,38593856-38593862,565653-565659,
    824824821-824824827,2121212118-2121212124
    "
    @assert part1(data) == 1227775554
    @assert part2(data) == 4174379265

    fn = isempty(args) ? "day2.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
