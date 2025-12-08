#!/usr/bin/env julia
using Graphs

const Pos = CartesianIndex{3}


function parsenotes(text)
    ps = [Pos(parse.(Int, l)...) for l in split.(split(text), ',')]
    n = length(ps)
    ds = [(distance(ps[i], ps[j]), i, j) for i in 1:n for j in i+1:n]
    return (ps, sort(ds))
end


function distance(a::Pos, b::Pos)
    sum(x*x for x in (b - a).I)
end


function part1(data, N=1000)
    ps,ds = parsenotes(data)
    g = SimpleGraph(length(ps))
    for (_,i,j) in ds[1:N]
        add_edge!(g, i, j)
    end
    qs = length.(connected_components(g))
    sort(qs, rev=true)[1:3] |> prod
end


function part2(data)
    ps,ds = parsenotes(data)
    g = SimpleGraph(length(ps))
    for (_,i,j) in ds
        add_edge!(g, i, j)
        is_connected(g) &&
            return ps[i][1] * ps[j][1]
    end
end


function @main(args)
    data = raw"""
    162,817,812
    57,618,57
    906,360,560
    592,479,940
    352,342,300
    466,668,158
    542,29,236
    431,825,988
    739,650,466
    52,470,668
    216,146,977
    819,987,18
    117,168,530
    805,96,715
    346,949,466
    970,615,88
    941,993,340
    862,61,35
    984,92,344
    425,690,689
    """
    @assert part1(data, 10) == 40
    @assert part2(data) == 25272

    fn = isempty(args) ? "day8.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
