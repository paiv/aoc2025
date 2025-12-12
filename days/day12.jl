#!/usr/bin/env julia

function parsenotes(text)
    ts..., ns = split(text, "\n\n", keepempty=false)
    shapes = [stack(split(s)[2:end], dims=1).=='#' for s in ts]
    regs = [(parse.(Int, split(r, 'x')), parse.(Int, split(t)))
        for s in split(ns, '\n', keepempty=false)
        for (r,t) in [split(s, ':')]]
    return (shapes, regs)
end



function tryfit(shapes, reg, ns)
    sum(ns) <= prod(reg .÷ 3)
end


function part1(data)
    shapes, regs = parsenotes(data)
    mapreduce(+, regs) do (r, ns)
        tryfit(shapes, r, ns)
    end
end


function @main(args)
    data = raw"""
    0:
    ###
    ##.
    ##.

    1:
    ###
    ##.
    .##

    2:
    .##
    ###
    ##.

    3:
    ##.
    ###
    ##.

    4:
    ###
    #..
    ###

    5:
    ###
    .#.
    ###

    4x4: 0 0 0 0 2 0
    12x5: 1 0 1 0 2 2
    12x5: 1 0 1 0 3 2
    """
    #@assert part1(data) == 2

    fn = isempty(args) ? "day12.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    return 0
end
