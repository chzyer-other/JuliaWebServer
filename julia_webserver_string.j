function +(str1::ASCIIString, str2::ASCIIString)
    strcat(str1, str2)
end
function replace(s::ASCIIString, ss::Char, sss::ASCIIString)
    replace(s, Regex(UTF8String([uint8(ss)])), sss)
end

function URLDecode(str)
    str = replace(str, "+", "%20")
    chars = split(str, '%')
    if length(chars) <= 1
        return str
    end
    strs = ""
    for i=chars
        global strs
        if length(i) < 2
            continue
        end
        strs = strcat(strs, UTF8String([hextoten(i[1:2])]), i[3:])
    end
    strs
end

function hextoten(num)
    len = length(num)
    num = uppercase(num)
    index = 0
    total = 0x0
    for i=num
        index += 1
        count = 0
        if int(i) <= 57
            count = int(i) - 48
        else
            count = int(i) - 55
        end
        count = count * 16^(len-index)
        total += count
    end
    convert(Uint8, total)
end