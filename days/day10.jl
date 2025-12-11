#!/usr/bin/env julia
import HiGHS
using JuMP


function parseline(text)
    g, bs..., ts = split(text)
    g = collect(g[2:end-1]) .== '#'
    bs = [parse.(Int,split(s[2:end-1], ',')) for s in bs]
    ns = parse.(Int, split(ts[2:end-1], ','))
    return (g, bs, ns)
end


function parsenotes(text)
    parseline.(split(text, '\n', keepempty=false))
end


function solve1(g, bs)
    goal = evalpoly(2, g)
    ms = [sum(1<<i for i in x) for x in bs]
    fringe = [(0, 0)]
    seen = Set{Int}()
    for (w, p) in fringe
        p == goal && return w
        p in seen && continue
        push!(seen, p)
        for x in ms
            push!(fringe, (w+1, p⊻x))
        end
    end
end


function mip(A, b)
    hi = optimizer_with_attributes(HiGHS.Optimizer,
        MOI.Silent()=>true)
    opt = Model(hi)
    @variable(opt, x[axes(A,2)], Int)
    @objective(opt, Min, sum(x))
    @constraint(opt, x .>= 0)
    @constraint(opt, A * x == b)
    optimize!(opt)
    @assert termination_status(opt) == MOI.OPTIMAL
    objective_value(opt)
end


function solve2(bs, goal)
    m = [(i-1) ∈ t for i in keys(goal), t in bs]
    # size(m,1) == size(m,2) == rank(m) && return sum(m\goal)
    mip(m, goal)
end


function part1(data)
    mapreduce(+, parsenotes(data)) do (g, bs)
        solve1(g, bs)
    end
end


function part2(data)
    mapreduce(+, parsenotes(data)) do (_, bs, ns)
        solve2(bs, ns)
    end |> Int
end


function @main(args)
    data = raw"""
    [.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
    [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
    [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    """
    @assert part1(data) == 7
    @assert part2(data) == 33

    fn = isempty(args) ? "day10.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
