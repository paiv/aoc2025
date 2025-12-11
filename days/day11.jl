#!/usr/bin/env julia

function parsenotes(text)
    Dict(a=>split(b)
        for line in split(text, '\n', keepempty=false)
        for (a,b) in [split(line, ':')])
end


function part1(data)
    g = parsenotes(data)
    start, goal = "you", "out"
    memo = Dict{AbstractString,Int}()
    function inner(p)
        p == goal && return 1
        get!(memo, p) do
            sum(inner, g[p])
        end
    end
    inner(start)
end


function part2(data)
    g = parsenotes(data)
    start, goal = "svr", "out"
    m = Dict("dac"=>1, "fft"=>2)
    memo = Dict{Tuple{AbstractString,Int},Int}()
    function inner(p, acc)
        p == goal && return (acc == 3)
        get!(memo, (p,acc)) do
            t = get(m, p, 0)
            inner.(g[p], acc|t) |> sum
        end
    end
    inner(start, 0)
end


function viz(data)
    g = parsenotes(data)
    edges = join("""$a -> $b\n"""
        for (a,cs) in g for b in cs)
    """
    digraph {
    bgcolor = "#202124"
    node [color = "#5F626B", fontcolor = "#f1f3f4"]
    edge [color = "#5F626B", fontcolor = "#f1f3f4"]
    $edges
    }
    """ |> println
end


function @main(args)
    data = raw"""
    aaa: you hhh
    you: bbb ccc
    bbb: ddd eee
    ccc: ddd eee fff
    ddd: ggg
    eee: out
    fff: out
    ggg: out
    hhh: ccc fff iii
    iii: out
    """
    @assert part1(data) == 5

    data = raw"""
    svr: aaa bbb
    aaa: fft
    fft: ccc
    bbb: tty
    tty: ccc
    ccc: ddd eee
    ddd: hub
    hub: fff
    eee: dac
    dac: fff
    fff: ggg hhh
    ggg: out
    hhh: out
    """
    @assert part2(data) == 2

    (verbose = "-v" in args) && popat!(args, findfirst(==("-v"), args))
    fn = isempty(args) ? "day11.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    verbose && (viz(data); return 0)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
