module configparser

export Read, ConfInt, ConfBool

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
                key, value = split(data, r"\s*=\s*")
                dictdata[SectionKey][key] = string(value)
            end
        end
    end
    return dictdata
end

function ConfInt(str)
    if match(r"^\d+$", str) != Nothing()
        num = 0
        len = length(str)
        for i in 1:len
            num += (Int(Char(str[i]))-48)*(10^(len-i))
        end
        return num
    else
        error("StringNumericalError")
    end
end

function ConfBool(str)
    if match(r"((TRUE|true)|(ENALBE|enable))", str) != Nothing()
        return true
    elseif match(r"((FALSE|false)|(DISABLE|disable))", str) != Nothing()
        return false
    else
        error("StringBooleanError")
    end
end

end