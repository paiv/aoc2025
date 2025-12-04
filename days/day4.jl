#!/usr/bin/env julia

const Pos = CartesianIndex{2}
const (U,D,L,R) = [(-1,0),(1,0),(0,-1),(0,1)] .|> Pos
const neibs = [U,D,L,R,U+R,D+R,D+L,U+L]


function parsenotes(text)
    grid = stack(split(text), dims=1) .== '@'
end


function avail(grid)
    [p for p in findall(grid)
        if count(get(grid, q, false) for q in p .+ neibs) < 4]
end


function part1(data)
    grid = parsenotes(data)
    avail(grid) |> length
end


function part2(data)
    grid = parsenotes(data)
    res = 0
    while true
        ix = avail(grid)
        isempty(ix) && return res
        res += length(ix)
        grid[ix] .= false
        #viz(grid, ix)
    end
end


function viz(grid, poi=Pos[]; fps=1.0)
    buf = IOBuffer()
    io = IOContext(buf, :color=>true)
    ix = avail(grid)
    for r in eachrow(keys(grid))
        for p in r
            c = grid[p] ? '@' : '.'
            if p in poi
                printstyled(io, 'x', color=:magenta)
            elseif p in ix
                printstyled(io, c, color=:blue)
            else
                print(io, c)
            end
        end
        println(io)
    end
    println(take!(buf) |> String)
    fps > 0 && sleep(1/fps)
end


function @main(args)
    data = raw"
    ..@@.@@@@.
    @@@.@.@.@@
    @@@@@.@.@@
    @.@@@@..@.
    @@.@@@@.@@
    .@@@@@@@.@
    .@.@.@.@@@
    @.@@@.@@@@
    .@@@@@@@@.
    @.@.@@@.@.
    "
    @assert part1(data) == 13
    @assert part2(data) == 43

    fn = isempty(args) ? "day4.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
