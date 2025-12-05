#!/usr/bin/env julia


nums(s) = [parse(Int, m[1]) for m in eachmatch(r"(\d+)", s)]

function parsenotes(text)
    t, ns = split(text, "\n\n", keepempty=false) .|> nums
    rs = range.(t[1:2:end], t[2:2:end])
    return (rs, ns)
end


function part1(data)
    rs, ns = parsenotes(data)
    count(ns) do x
        any(x in r for r in rs)
    end
end


function part2(data)
    rs, = parsenotes(data)
    rs = sort(rs, by=first)
    res = s = e = 0
    for r in rs
        s, x = max(first(r), e), last(r)+1
        if x > s
            res += x - s
            e = x
        end
    end
    return res
end


function viz(data; h::Real=480, w::Real=1024)
    rs,ns = parsenotes(data)
    minx, maxx = minimum(first, rs), maximum(last, rs)
    maxy = length(rs)
    sy, sx = h/(maxy+1), w/(maxx+1)
    lw = round(log10(h), digits=4)

    function ln(y, r)
        y = round(y * sy, digits=4)
        a = round(first(r) * sx, digits=4)
        b = round(last(r) * sx, digits=4)
        """<line x1="$a" y1="$y" x2="$b" y2="$y" stroke="#ffdecfcc" stroke-width="$lw"/>\n"""
    end

    lines = join(ln(y, r) for (y,r) in pairs(rs))

    """
<?xml version="1.0"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg xmlns="http://www.w3.org/2000/svg"
      width="$w" height="$h" style="background-color:#202124">
  $lines
</svg>
    """
end


function @main(args)
    data = raw"
    3-5
    10-14
    16-20
    12-18

    1
    5
    8
    11
    17
    32
    "
    @assert part1(data) == 3
    @assert part2(data) == 14

    (verbose = "-v" in args) &&
        deleteat!(args, findfirst(==("-v"), args))
    fn = isempty(args) ? "day5.in" :
        args[1] == "-" ? stdin : args[1]
    data = readchomp(fn)
    verbose && (println(viz(data)); exit())
    println("part1: ", part1(data))
    println("part2: ", part2(data))
    return 0
end
