
const DEFAULT_PROTOCOL = "HTTP/1.1"
const DEFAULT_METHOD = "GET"
const DEFAULT_PATH = "/"

load("./ui/webserver/message_types.h")

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

type __Header
    method::String
    path::String
    protocol::String
    data::HashTable
end

function __read_message()
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
                if has(__data, "Content-Length") && int(__data["Content-Length"]) > 0
                    argstring = read(__io, Uint8, int(__data["Content-Length"]))
                    argstring = UTF8String(argstring)
                    __args = split(argstring, '&')
                    args_hash = HashTable()
                    for arg_string = __args
                        (key, value) = match(r"^([^=]+)=(.*)$", arg_string).captures
                        args_hash[key] = URLDecode(value)
                    end
                    __data["args"] = args_hash
                end
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
            __data[key] = value
        end
        line_index += 1
    end
    __Header(__method, __path, __protocol, __data)
end

function __socket_callback(fd)
    # read the message
    __msg = __read_message()
    put(__eval_channel, (fd, __msg))

end

# event handler for socket input

function __eval_exprs(__parsed_exprs)
    (fd, __msg) = __parsed_exprs
    f = nothing
    match_route = false
    for i = __handlers
        m = match(i[1], __msg.path)
        if m != nothing && m.match == __msg.path            
            match_route = true
            f = get_func(__msg)
            if __msg.method == "GET" && i[2].get != nothing
                i[2].get(f)
            elseif __msg.method == "POST" && i[2].post != nothing
                i[2].post(f)
            else
                f.senderror(405)
            end
            break
        end
    end
    
    if match_route
        html = f.data["html"]
        status = f.data["status"]
    else
        status = __htmlfunc_senderror(404)
        html = status
    end
    global __io, __connectfd
    write(__io, "$DEFAULT_PROTOCOL $status\n")
    write(__io, "Server: Microsoft-IIS/5.0\n")
    write(__io, "Content-Length: $(length(html))\n")
    write(__io, "Content-Type: text/html\n\n")
    write(__io, "$html\n")
    flush(__io)
    close(__io)
    __connectfd = ccall(:accept, Int32, (Int32, Ptr{Void}, Ptr{Void}), __sockfd, C_NULL, C_NULL)
    __io = fdio(__connectfd, true)
end

type Func
    data::HashTable
    header::__Header
    write::Function
    senderror::Function
    get_argument::Function
end

type Handler
    get::Union(Function, Nothing)
    post::Union(Function, Nothing)
end


function __htmlfunc_write(html, str)
    strcat(html, str)
end

function __htmlfunc_senderror(code)
    lib = {
        200 => "OK", 
        301 => "Moved Permanently",
        302 => "Found",
        304 => "Forbidden",
        304 => "Not Modified",
        404 => "Not Found",
        405 => "Method Not Allowed",
        408 => "Request Timeout",
        500 => "Internal Server Error",
        502 => "Bad Gateway",
        504 => "Gateway Timeout"
    }
    "$code $(lib[code])"
end

function get_func(header)
    data = {"html" => "", "status" => "200 OK"}
    func_base = Func(
        data,header,
        function (str)
            func_base.data["html"] = strcat(func_base.data["html"], ASCIIString(str.data))
        end,
        function (code)
            func_base.data["status"] = __htmlfunc_senderror(code)
            func_base.data["html"] = func_base.data["status"]
        end,
        function (field, default)
            println(func_base.header)
            if has(func_base.header.data, "args") && has(func_base.header.data["args"], field)
                return func_base.header.data["args"][field]
            end
            default
        end
    )
end



__ports = nothing
__sockfd = nothing
__connectfd = nothing
__io = nothing
__eval_channel = RemoteRef()
function loop()
    global __connectfd, __io, __port, __sockfd
    __ports = [int16(4444)]
    __sockfd = ccall(:open_any_tcp_port, Int32, (Ptr{Int16},), __ports)
    if __sockfd == -1
        # couldn't open the socket
        println("could not open server socket on port 4444.")
        exit()
    end
    println(__ports)
    __connectfd = ccall(:accept, Int32, (Int32, Ptr{Void}, Ptr{Void}), __sockfd, C_NULL, C_NULL)
    __io = fdio(__connectfd, true)
    add_fd_handler(__connectfd, __socket_callback)    
    while true
        __eval_exprs(take(__eval_channel))
    end
end
