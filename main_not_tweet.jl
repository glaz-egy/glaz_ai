using MeCab

function next(datalist, startstring; BOS=false, num=3)
    if num == 2
        next =  rand([data for data in datalist if BOS ? data[1] == startstring[1] : data[1] == startstring[2]])
    elseif num == 3
        next =  rand([data for data in datalist if (data[1] == startstring[1]) && (BOS || data[2] == startstring[2])])
    end
    println(next)
    return num == 2 ? next : next[2:3]
end

function DataCreate(texts; num=3)
    text = string(lstrip(texts))
    mecab = Mecab()
    results = parse(mecab, text)
    data = []
    for i in 1:length(results) + (num == 2 ? 1 : 0)
        if num == 2
            push!(data, [i == 1 ? "BOS" : results[i-1].surface, i < length(results)+1 ? results[i].surface : "EOS"])
        elseif num == 3
            push!(data, [i == 1 ? "BOS" : results[i-1].surface, results[i].surface, i < length(results) ? results[i+1].surface : "EOS"])
        end
    end
    return data
end

function Markov(data; num=3)
    nextstring = next(data, ["BOS"], BOS=true, num=num)
    out = nextstring[1] == "BOS" ? "" : nextstring[1]
    while true
        if nextstring[2] == "EOS"
            return out
        end
        out *= nextstring[2]
        nextstring = next(data, nextstring, num=num)
        if length(out) > 140
            i = 0
            nextstring = next(data, ["BOS"], BOS=true, num=num)
            out = (nextstring[1] == "BOS" ? "" : nextstring[1]) * nextstring[2]
        end
    end
end

open("textdata.txt", "r") do fp
    textdata = readlines(fp)
    datalist = []
    for text in textdata
        append!(datalist, DataCreate(text))
    end
    while true
        n = readline()
        if n == "e"
            break
        else
            println(Markov(datalist))         
        end
    end
end