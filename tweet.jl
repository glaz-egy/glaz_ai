module tweet

    using Twitter
    using JLD2

    export init, UpdateTextData, PostTweet

    function init()
        NeedKeys = ["CK", "CS", "AT", "ATS"]
        KeyDict = Dict("CK" => "0", "CS" => "0", "AT" => "0", "ATS" => "0")
        f = jldopen("api.conf", "a+")
        for key in NeedKeys
            if !haskey(f, key)
                print("Your $key please: ")
                input = readline()
                f[key] = input
                KeyDict[key] = input
            else
                KeyDict[key] = f[key]
            end
        end
        if !haskey(f, "ID")
            print("Your ID pleace: ")
            input = readline()
            f["ID"] = input
            ID = input
        else
            ID = f["ID"]
        end
        ID = split(ID, "@")
        close(f)
        return (KeyDict, ID)
    end

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

    function GetTweet(;count=300)
        if string(typeof(ID)) != "SubString{String}"
            textlist = []
            for id in ID
                timelines = get_user_timeline(id=id, count=300)
                append!(textlist, TweetText(timelines))
            end
        end
        return textlist
    end

    function AppendFile(filename, text)
        open(filename, "a") do f
            write(f, text*"\n")
        end
    end

    function ReadFile(filename)
        filedata = open(filename, "r") do f
            readlines(f)
        end
    end

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

    KeyDict, ID = init()
    twitterauth(KeyDict["CK"], KeyDict["CS"], KeyDict["AT"], KeyDict["ATS"])
end