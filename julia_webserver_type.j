type __Header
    method::String
    path::String
    protocol::String
    data::HashTable
end

type Func
    data::HashTable
    header::__Header
    write::Function
    senderror::Function
    get_argument::Function
    set_cookie::Function
    get_cookie::Function    
end

type Handler
    get::Union(Function, Nothing)
    post::Union(Function, Nothing)
end