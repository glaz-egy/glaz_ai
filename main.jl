include("tweet.jl")
include("configparser.jl")

using Dates
using MeCab
using .tweet
using .configparser

function logwrite(file, logtext)
    open(file, "a") do f
        write(f, logtext)
    end
end

function next(datalist, startstring; BOS=false, num=2)
    if num == 2
        next =  rand([data for data in datalist if BOS ? data[1] == startstring[1] : data[1] == startstring[2]])
    elseif num == 3
        next =  rand([data for data in datalist if (data[1] == startstring[1]) && (BOS || data[2] == startstring[2])])
    end
    println(next)
    return next, (num == 2 ? next : next[2:3])
end

function DataCreate(texts; num=2)
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

function Markov(data, nowhash; num=2)
    marklist = ""
    all, nextstring = next(data, ["BOS"], BOS=true, num=num)
    out = nextstring[1] == "BOS" ? "" : nextstring[1]
    marklist *= nowhash*string(all)*"\n"
    while true
        if nextstring[2] == "EOS"
            return out, marklist
        end
        out *= nextstring[2]
        all, nextstring = next(data, nextstring, num=num)
        marklist *= nowhash*string(all)*"\n"
        if length(out) > 140
            i = 0
            all, nextstring = next(data, ["BOS"], BOS=true, num=num)
            out = nextstring[1] == "BOS" ? "" : nextstring[1]
            marklist *= nowhash*string(all)*"\n"
        end
    end
end

function main(nowhash)
    AutoFollow()
    textdata = UpdateTextData()
    datalist = []
    for text in textdata
        append!(datalist, DataCreate(text, num=num))
    end
    str, processes = Markov(datalist, nowhash, num=num)
    if in(str, textdata)
        while in(str, textdata)
            println("fail text: $str")
            logwrite("ai.log", processes*nowhash*" fail text: $str\n")
            str, processes = Markov(datalist, nowhash, num=num)
        end
    end
    println(str)
    logwrite("ai.log", processes*nowhash*" success: $str\n")
    PostTweet(str)
end

const config = Read("bot.ini")
const num = ConfInt(config["CONF"]["num"])
const time = ConfInt(config["CONF"]["time"])

while true
    try
        nowtime = "["*string(now())*"]"
        timehash = "["*string(hash(nowtime), base=16)*"]"
        println(nowtime)
        main(nowtime*timehash)
    catch err
        println("Can't Post tweet")
        println(err)
    end
    sleep(time)
end