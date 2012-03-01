###########################################
# protocol
###########################################

###### the julia<-->server protocol #######

# the message type is sent as a byte
# the next byte indicates how many arguments there are
# each argument is four bytes indicating the size of the argument, then the data for that argument

###### the server<-->browser protocol #####

# messages are sent as arrays of arrays (json)
# the outer array is an "array of messages"
# each message is itself an array:
# [message_type::number, arg0::string, arg1::string, ...]

# import the message types
load("./ui/webserver/message_types.h")

###########################################
# set up the socket connection
###########################################

# open a socket on any port
__ports = [int16(4444)]
__sockfd = ccall(:open_any_tcp_port, Int32, (Ptr{Int16},), __ports)
if __sockfd == -1
    # couldn't open the socket
    println("could not open server socket on port 4444.")
    exit()
end

# print the socket number so the server knows what it is
println(__ports[1])

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
    __method = "GET"
    __path = "/"
    __protocol = "HTTP/1.1"
    __data = HashTable()
    while true
        line = __readline()
        if length(line) <= 1
            break
        end
        if line_index == 0
            m = match(r"^(\w+)\s([^\s]+)\s([^\n\r]+)", line)
            (__method, __path, __protocol) = m.captures
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
    html = ""
    status = "200 OK"
    f = nothing
    for i = __handlers
        m = match(i[1], __msg.path)
        if m != nothing && m.match == __msg.path            
            f = get_func()
            if __msg.method == "GET"
                i[2].get(f)
            else __msg.method == "POST"
                i[2].post(f)
            end
            break
        end
    end
    html = f.data["html"]
    global __io, __connectfd
    write(__io, "HTTP/1.1 $status\n")
    write(__io, "Server: Microsoft-IIS/5.0\n")
    write(__io, strcat("Content-Length: $(length(html))\n"))
    write(__io, "Content-Type: text/html\n\n")
    write(__io, "$html\n")
    flush(__io)
    close(__io)
    __connectfd = ccall(:accept, Int32, (Int32, Ptr{Void}, Ptr{Void}), __sockfd, C_NULL, C_NULL)
    __io = fdio(__connectfd, true)
end

type Func
    data::HashTable
    write::Function
    senderror::Function
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
    status = "$code $(lib[code])"
end

function get_func()
    data = HashTable()
    data["html"] = ""
    func_base = Func(
        data,
        function (str)
            func_base.data["html"] = __htmlfunc_write(func_base.data["html"], str)
        end,
        function (code)
            status = __htmlfunc_senderror(code)
            func_base.data["html"] = status
        end,
    )
end

__connectfd = nothing
__io = nothing
__eval_channel = RemoteRef()
function loop()
    global __connectfd, __io
    __connectfd = ccall(:accept, Int32, (Int32, Ptr{Void}, Ptr{Void}), __sockfd, C_NULL, C_NULL)
    __io = fdio(__connectfd, true)
    add_fd_handler(__connectfd, __socket_callback)    
    while true
        __eval_exprs(take(__eval_channel))
    end
end
