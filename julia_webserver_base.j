
const DEFAULT_PROTOCOL = "HTTP/1.1"
const DEFAULT_METHOD = "GET"
const DEFAULT_PATH = "/"
const LIB_PATH = "/home/cheney/juliawebserver/"
const LIB_FILE_PREFIX = strcat(LIB_PATH, "julia_webserver_")

function load(mods)
    for mod = mods
        load(strcat(LIB_FILE_PREFIX, mod, ".j"))
    end
end

load(["func_string", "type", "func_iostream"])
load("./ui/webserver/message_types.h")





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
    data = {"html" => "", "status" => "200 OK", "cookie" => []}
    func_base = Func(
        data,header,

        #write
        function (str)
            if str == nothing
                return
            end
            func_base.data["html"] = strcat(func_base.data["html"], ASCIIString(str.data))
        end,

        #senderror
        function (code)
            func_base.data["status"] = __htmlfunc_senderror(code)
            func_base.data["html"] = func_base.data["status"]
        end,

        #get_argument
        function (field, default)
            if has(func_base.header.data, "args") && has(func_base.header.data["args"], field)
                return func_base.header.data["args"][field]
            end
            default
        end,

        #set cookie
        function (field, value)
            func_base.data["cookie"] = append(func_base.data["cookie"], [strcat(field, "=", value)])
        end,

        #get cookie
        function (field, default)
            if has(func_base.header.data, "Cookie") && has(func_base.header.data["Cookie"], field)
                return func_base.header.data["Cookie"][field]
            end
            default
        end
    )
end

function __socket_callback(fd)
    __msg = __read_header()
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
                # method not allow
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
    __write_back(html, status, f.data["cookie"])
    __connect()
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
    __connect()
    add_fd_handler(__connectfd, __socket_callback)    
    while true
        __eval_exprs(take(__eval_channel))
    end
end
