#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [U,D,L,R]


function parsenotes(text)
    [Pos(parse.(Int, [m[2],m[1]])...)
        for m in eachmatch(r"(\d+),(\d+)", text)]
end


function rect(a::Pos, b::Pos)
    ay,by = minmax(a[1], b[1])
    ax,bx = minmax(a[2], b[2])
    Pos(ay,ax):Pos(by,bx)
end


area(a::Pos, b::Pos) = prod(size(rect(a, b)))


function part1(data)
    gs = parsenotes(data)
    res = 0
    for a in gs, b in gs
        if a < b
            res = max(res, area(a, b))
        end
    end
    return res
end


function part2(data)
    gs = parsenotes(data)
    push!(gs, first(gs))
    ys = unique(p[1] for p in gs) |> sort
    xs = unique(p[2] for p in gs) |> sort
    ys = [0; ys; ys[end]+1]
    xs = [0; xs; xs[end]+1]
    ps = [Pos(y,x) for y in ys, x in xs]
    ix = [ps[i] ∈ gs for i in keys(ps)]
    m = falses(size(ps))
    for i in 2:length(gs)
        a = findfirst(==(gs[i-1]), ps)
        b = findfirst(==(gs[i]), ps)
        a,b = minmax(a, b)
        m[a:b] .= true
    end
    fringe = [Pos(1,1)]
    outer = Set{Pos}()
    while !isempty(fringe)
        p = pop!(fringe)
        p in outer && continue
        push!(outer, p)
        for q in p .+ neibs
            get(m,q,nothing)==false && push!(fringe, q)
        end
    end
    m[[i for i in keys(m) if i ∉ outer]] .= true
    res = 0
    us = findall(ix)
    for i in us, j in us
        j >= i && continue
        a, b = extrema(rect(i, j))
        if all(m[a:b])
            p = area(ps[a], ps[b])
            res = max(res, p)
        end
    end
    return res
end


function @main(args)
    data = raw"""
    7,1
    11,1
    11,7
    9,7
    9,5
    2,5
    2,3
    7,3
    """
    @assert part1(data) == 50
    @assert part2(data) == 24

    fn = isempty(args) ? "day9.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
