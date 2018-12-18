module configparser

export Read

function Read(filename)
    filedata = readlines(filename)
    dictdata = Dict()
    SectionKey = ""
    for data in filedata
        if match(r"\[.*\]", data) != Nothing()
            data = replace(data, r"(\[|\])" => "")
            SectionKey = data
            dictdata[SectionKey] = Dict()
        else
            if match(r"^\s+", data) == Nothing() && data != ""
                key, value = split(data, r"\s=\s")
                dictdata[SectionKey][key] = string(value)
            end
        end
    end
    return dictdata
end

end