#!/usr/bin/env julia
import DataStructures: counter

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [2U, U+3R, D+3R, 2D, D+3L, U+3L]


function parsenotes(text)
    lines = split(text, '\n', keepempty=false) .|> rstrip
    w = length.(lines) |> maximum
    s = stack(rpad.(lines, w), dims=1)
    ix = findall(∈('0':'4'), s)
    g = fill(-1, size(s))
    g[ix] .= parse.(Int, s[ix])
    s[ix] .= ' '
    return (g, s)
end


function lightmap1(grid, t, m, hs)
    i = mod(t, 1:4)
    d = [D,L,U,R][i]
    s = i == 1 ? Pos.(1, 2:3:size(grid, 2)) :
        i == 2 ? Pos.(axes(grid, 1), size(grid, 2)) :
        i == 3 ? Pos.(size(grid, 1), 2:3:size(grid, 2)) :
        Pos.(axes(grid, 1), 1)
    m .= false
    m[s] .= true
    hs[s] = grid[s]
    while checkbounds(Bool, grid, s[1]+d)
        q = s .+ d
        m[q] = @. (grid[q] <= 0 >= hs[s]) || (grid[q] > hs[s])
        hs[q] = max.(hs[s], grid[q])
        s = q
    end
end


function lightmap2(grid, t, m, hs)
    lightmap1(grid, t, m, hs)
    s = findall(m .& (grid .> 0))
    i = mod(t, 1:4)
    dv = i == 1 ? [neibs[3], neibs[5]] :
        i == 2 ? [neibs[5], neibs[6]] :
        i == 3 ? [neibs[2], neibs[6]] :
        [neibs[2], neibs[3]]
    for p in s, d in dv
        w, h = 0, grid[p]
        q = p + d
        while (w < h) && checkbounds(Bool, grid, q)
            m[q] |= (grid[q] <= 0 >= w) || (grid[q] > w)
            w = max(w, grid[q])
            q += d
        end
    end
end


function evolve!(light, grid, lm, N=1; t0=0)
    hs = zeros(Int, size(grid))
    xx = [Pos.(1, axes(grid,2)); Pos.(size(grid,1), axes(grid,2))]
    res = 0
    light(grid, t0+1, lm, hs)
    for t in 1:N
        cs = counter(q for (i,x) in pairs(grid) if x >= 2
           for q in i .+ neibs if get(grid, q, 0) < 0 && q ∉ xx)
        us = findall(>=(2), cs)
        ix = findall(>=(0), grid)
        grid[ix] += lm[ix]
        grid[us] += lm[us]
        jx = findall(>=(5), grid)
        res += length(jx)
        grid[jx] .= -1
        light(grid, t0+t+1, lm, hs)
    end
    return res
end


function part1(data, N=256)
    g, = parsenotes(data)
    lm = falses(size(g))
    evolve!(lightmap1, g, lm, N)
end


function part2(data, N=256)
    g, = parsenotes(data)
    lm = falses(size(g))
    evolve!(lightmap2, g, lm, N)
end


function viz(grid, lm, bg; fps=1.0)
    palette = [0, 50, 45, 40, 34, 3, 248]
    m = copy(bg)
    ix = findall(>=(0), grid)
    m[ix] = grid[ix] .+ '0'
    buf = IOBuffer()
    io = IOContext(buf, :color=>true)
    for r in eachrow(keys(m))
        for p in r
            x = m[p]
            j = x in '0':'4' ? (lm[p] ? x-'0'+2 : 1) : lm[p] ? 7 : 1
            printstyled(io, x, color=palette[j])
        end
        println(io)
    end
    println(take!(buf) |> String)
    fps > 0 && sleep(1/fps)
end


function play(data, N=256)
    g, ws = parsenotes(data)
    lm = falses(size(g))
    ans = 0
    for t in 1:N
        ans += evolve!(lightmap1, g, lm, t0=t-1)
        @show t ans
        viz(g, lm, ws)
    end
end


function @main(args)
    data = raw"""
     __    __    __    __
    /  \__/  \__/  \__/1 \__
    \__/2 \__/3 \__/  \__/  \
    /  \__/  \__/  \__/0 \__/
    \__/4 \__/  \__/2 \__/  \
    /  \__/  \__/  \__/  \__/
    \__/  \__/0 \__/0 \__/  \
    /2 \__/0 \__/  \__/  \__/
    \__/  \__/  \__/  \__/  \
       \__/  \__/  \__/  \__/
    """
    @assert part1(data) == 529
    @assert part2(data) == 1117

    (verbose = "-v" in args) && popat!(args, findfirst(==("-v"), args))
    fn = isempty(args) ? "infi.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    verbose && play(data)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
