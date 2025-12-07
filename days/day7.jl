#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos


function parsenotes(text)
    grid = stack(split(text), dims=1)
    start = findfirst(==('S'), grid)
    return (grid, start)
end


function part1(data)
    grid, start = parsenotes(data)
    fringe = [start]
    res = 0
    for _ in 2:size(grid,1)
        v = fringe .+ D
        res += count(==('^'), grid[v])
        fringe = unique(p for i in v
            for p in (grid[i] == '^' ? [i+L,i+R] : [i]))
    end
    return res
end


function part2(data)
    grid, start = parsenotes(data)
    h = size(grid, 1)
    memo = Dict{Pos,Int}()
    function inner(p)
        p[1] > h && return 1
        get!(memo, p) do
            if grid[p] == '^'
                inner(p+L) + inner(p+R)
            else
                inner(p+D)
            end
        end
    end
    inner(start)
end


function @main(args)
    data = raw"""
    .......S.......
    ...............
    .......^.......
    ...............
    ......^.^......
    ...............
    .....^.^.^.....
    ...............
    ....^.^...^....
    ...............
    ...^.^...^.^...
    ...............
    ..^...^.....^..
    ...............
    .^.^.^.^.^...^.
    ...............
    """
    @assert part1(data) == 21
    @assert part2(data) == 40

    fn = isempty(args) ? "day7.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
