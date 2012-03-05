function __readline()
    global __io
    line = ""
    while true
        char = read(__io, Char)
        if char == '\n'
            break
        end
        line = strcat(line, char)
    end
    line
end

function __write_back(html, status, cookie)
    global __io, __connectfd
    write(__io, "$DEFAULT_PROTOCOL $status\n")
    write(__io, "Server: Microsoft-IIS/5.0\n")
    write(__io, "Content-Length: $(length(html))\n")
    if length(cookie) > 0
        for i = cookie
            write(__io, "Set-Cookie: $i\n")
        end
    end
    write(__io, "Content-Type: text/html; charset=UTF-8\n\n")

    write(__io, "$html\n")
    flush(__io)
    close(__io)
end

function __connect()
    global __connectfd, __io
    __connectfd = ccall(:accept, Int32, (Int32, Ptr{Void}, Ptr{Void}), __sockfd, C_NULL, C_NULL)
    __io = fdio(__connectfd, true)
end

function __read_cookie(data)
    cookies = HashTable()

    cookies
end

function __read_header()
    line_index = 0
    __method = DEFAULT_METHOD
    __path = DEFAULT_PATH
    __protocol = DEFAULT_PROTOCOL
    __data = HashTable()
    post_read_more_line = false
    while true
        line = __readline()
        if length(line) <= 1
            if post_read_more_line
                post_read_more_line = false
                __data["args"] = __read_arguments_from_header(__data)
            end
            break
        end
        if line_index == 0
            m = match(r"^(\w+)\s([^\s]+)\s([^\n\r]+)", line)
            (__method, __path, __protocol) = m.captures
            if __method == "POST"
                post_read_more_line = true
            end
        else
            m = match(r"^([\w\-]+)\:\s([^\n\r]+)", line)
            (key, value) = m.captures
            if key == "Cookie"
                local tmp = split(value, ';')
                local cookies = HashTable()
                for cookie_item = tmp
                    (cookie_filed, cookie_value) = match(r"^\s*(\w+)=(.*)$", cookie_item).captures
                    cookies[cookie_filed] = cookie_value
                end
                __data[key] = cookies
            else
                __data[key] = value
            end
        end
        line_index += 1
    end
    __Header(__method, __path, __protocol, __data)
end

function __read_arguments_from_header(__data)
    if has(__data, "Content-Length") == false || int(__data["Content-Length"]) <= 0
        return __data
    end
    argstring = read(__io, Uint8, int(__data["Content-Length"]))
    argstring = UTF8String(argstring)
    __args = split(argstring, '&')
    args_hash = HashTable()
    for arg_string = __args
        (key, value) = match(r"^([^=]+)=(.*)$", arg_string).captures
        args_hash[key] = URLDecode(value)
    end

    args_hash    
end