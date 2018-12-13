using MeCab

function datacreate(texts)
    text = string(lstrip(texts))
    mecab = Mecab()
    results = parse(mecab, text)
    data = []
    for i in 1:length(results)+1
        if i == 1
            push!(data, ["BOS", results[i].surface])
        elseif i != length(results)+1
            push!(data, [results[i-1].surface, results[i].surface])
        else
            push!(data, [results[i-1].surface, "EOS"])
        end
    end
    return data
end

function next(datalist, startstring)
    nextlist = [data for data in datalist if data[1] == startstring]
    rand(nextlist)[2]
end

function Markov(data)
    i = 0
    ne = next(data, "BOS")
    out = ne
    while true
        ne = next(data, ne)
        if ne == "EOS"
            return out
        end
        out = out * ne
        i += 1
        #=if i > 20
            i = 0
            ne = next(data, "BOS")
            out = ne
        end=#
    end
end

open("textdata.txt", "r") do fp
    textdata = readlines(fp)
    datalist = []
    for text in textdata
        append!(datalist, datacreate(text))
    end
    while true
        if readline() == "n"
            println(Markov(datalist))
        else
            break         
        end
    end
end
