render_string(filename) = render_string(filename, HashTable())
function render_string(filename, data)
    lib = check_exist_lib(filename)
    if lib != nothing
        update_lib(filename)        
    end

    html = get_data(filename)
    if typeof(html) == HashTable{ASCIIString,Any}
        content = render_string(html["extend"], html)
    else
        content = html(data)
    end
    content
end

function addslashes(str)
    replace(str, "\"", "\\\"")
end

function replace_match(body, match_data::RegexMatch, replacement)
    prefix = body[1: match_data.offset - 1]
    tail = body[match_data.offset + length(match_data.match) :]
    start = 1
    while true
        m2 = match(r"\$(\d)", replacement, start)
        if m2 == nothing
            break
        end
        start = m2.offset + 1
        replacement = replace(replacement, m2.match, match_data.captures[int(m2.captures[1])])
    end
    strcat(prefix, replacement, tail)
end
replace_match(body, regex::Nothing, replacement) = body
replace_match(body, regex::Regex, replacement) = replace_match(body, match(regex, body), replacement)

function create_base_template(content)
    quot = "\"\"\""
    write_data = ""
    current_index = 1
    block_data = HashTable()
    while true
        match_block = match(r"{% block ([^\s]+) %}([^{]+){% end %}", content, current_index)
        if match_block == nothing
            break
        end
        current_index = match_block.offset + 1
        key, value = match_block.captures
        block_data[key] = value
        content = replace_match(content, match_block, "\$($key)")
        content = replace_match(content, r"{{ ([^\s]+) }}", "\$(\$1)")
    end
    for i = block_data
        data = strcat(quot, addslashes(i[2]), quot)
        write_data = strcat(write_data, i[1], " = has(data, \"$(i[1])\") ? data[\"$(i[1])\"] : ", data, "\n")
    end
    strcat(write_data, quot, content, quot, "\n")
end

function create_extend_template(match_extend, content)
    quot = "\"\"\""
    write_data = strcat("extend = \"", match_extend.captures[1], "\"\n")
    current_index = 1
    last_block_start = -1
    last_nest_start = -1
    current_block = ""
    return_field = []
    level = 0
    while true
        match_command = match(r"{% ([^\s]+?)(?:\s(.*?))? %}", content, current_index)
        if match_command == nothing
            break
        end
        current_index = match_command.offset + 1
        method = match_command.captures[1]

        if last_block_start > 0
            write_data = strcat(write_data, content[last_block_start: current_index - 2], quot, "\n")
            last_block_start = -1
        end

        if last_nest_start > 0
            write_data = strcat(write_data, make_nest_string(content, current_block, last_nest_start, current_index))
            last_nest_start = -1
        end

        nest_method = ["for", "if", "else", "elseif"]
        if contains(nest_method, method)
            last_nest_start = current_index + length(match_command.match) - 1
        elseif method == "block"
            last_block_start = current_index + length(match_command.match) - 1
        end

        level = get_level(method, level)
        if level == -1 && method == "end"
            level = 0
            continue
        end

        if method == "block"            
            current_block = match_command.captures[2]
            return_field = append(return_field, [current_block])
        end

        write_data = strcat(write_data, get_method_data(method, match_command))
    end
    write_data = strcat(write_data, "\t{\"extend\"=>", "extend,")
    for field = return_field
        write_data = strcat(write_data, "\"$field\"=>$field,")
    end
    write_data = strcat(write_data, "}\n")  
end

function make_nest_string(content, current_block, start, index)
    quot = "\"\"\""
    tmp_content = replace(content[start: index - 2], "\"", "\\\"")
    m = match(r"{{ (\w+) }}", tmp_content)
    if m != nothing
        tmp_content = strcat(tmp_content[1:m.offset-1], "\$(", m.captures[1], ")", tmp_content[m.offset + length(m.match):])
    end

    strcat("$current_block = strcat($current_block, ", quot,  tmp_content, quot, ")\n")
end

function get_level(method, level)
    high_level_method = ["for", "if"]
    if contains(high_level_method, method)
        level += 1
    elseif method == "end"            
        if level <= 0
            level = -1
        else
            level -= 1
        end
    end
    level
end

function get_method_data(method, match_command)
    quot = "\"\"\""
    if method == "block"
        return strcat(match_command.captures[2] , " = ", quot)
    elseif contains(["end", "else"], method)
        return strcat(method , "\n")
    elseif contains(["for", "if", "elseif"], method)
        return strcat(method, " ", match_command.captures[2], "\n")
    end
    return ""
end

function update_lib(filename)
    quot = "\"\"\""
    stream = open(strcat("./tpl/", filename, ".html"))
    content = readall(stream)
    write_data = ""
    match_extend = match(r"{% extend ([^\s]+) %}", content)
    write_data = strcat(write_data, "is_extend = ", match_extend == nothing ? "false" : "true", "\n")
    write_data = strcat(write_data, "function html(", match_extend == nothing ? "data" : "",")\n")
    if match_extend == nothing
        write_data = strcat(write_data, create_base_template(content))
    else
        write_data = strcat(write_data, create_extend_template(match_extend, content))      
    end
    write_data = strcat(write_data, "end")    
    write_data = UTF8String(write_data.data)
    stream = open(strcat("./cache/", filename, "_tpl.j"), "w")
    write(stream, write_data)
    flush(stream)
end

function check_exist_lib(filename)
    file_path = strcat("./tpl/", filename, ".html")
    if DEBUG
        return false
    end
    try
        s = open(file_path)
        return true
    catch x
        return true
    end
    false
end 

function get_data(filename)
    begin
        load(strcat("./cache/", filename, "_tpl.j"))
        if is_extend
            return html()
        else
            return html
        end
    end
end