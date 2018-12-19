module tweet
include("configparser.jl")

using .configparser
using Twitter

export UpdateTextData, PostTweet, AutoFollow

function TweetText(timelines)
    returnlist = []
    for timeline in timelines
        if timeline.retweeted_status == Nothing() && match(r"さん(より|から)", timeline.text) == Nothing()
            text = replace(timeline.text, r"http.*" => "")
            text = replace(text, r"#" => "")
            text = replace(text, r"@.*\s" => "")
            push!(returnlist, text)
        end
    end
    return returnlist
end

function PostTweet(text)
    post_status_update(status=text)
end

function GetTweet(;count=50)
    if match(r"@", config["User"]["user_id"]) != Nothing()
        ID = split(config["User"]["user_id"], "@")
        textlist = []
        for id in ID
            timelines = get_user_timeline(id=id, count=count)
            append!(textlist, TweetText(timelines))
        end
    else
        textlist = []
        timelines = get_user_timeline(id=config["User"]["user_id"], count=count)
        append!(textlist, TweetText(timelines))
    end
    return textlist
end

function AutoFollow()
    followers = get_followers_list()
    friends = get_friends_list()
    for user in followers["users"]
        if !user["following"]
            println(user["name"])
            post_friendships_create(id=user["id"])
        end
    end
end

function AppendFile(filename, text)
    open(filename, "a") do f
        write(f, text*"\n")
    end
end

ReadFile(filename) = readlines(filename)

function UpdateTextData()
    Textdata = ReadFile("textdata.txt")
    textlist = GetTweet()
    for text in textlist
        texts = split(text, "\n")
        if string(typeof(text)) != "SubString{String}"
            for text in texts
                text = string(strip(text))
                if !in(text, Textdata) && text != ""
                    AppendFile("textdata.txt", text)
                    push!(Textdata, text)
                end
            end
        else
            texts = string(strip(text))
            if !in(texts, Textdata) &&  texts != ""
                AppendFile("textdata.txt", texts)
                push!(Textdata, texts)
            end
        end
    end
    return Textdata
end

GetLimit() = get_application_rate_limit_status()

const config = Read("api.ini")
twitterauth(config["OAuth"]["consumer_key"], config["OAuth"]["consumer_secret"], config["OAuth"]["access_token_key"], config["OAuth"]["access_token_secret"])
end