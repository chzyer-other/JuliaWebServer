
a framework to make building website more easily 

<a name="JuliaWebServer-a-webserver-for-julia"/>
## JuliaWebServer : a webserver for julia
Base on julia <https://github.com/JuliaLang/julia>

## How to Start

see the sub directory "example" .

1. open the file `julia_webserver_base.j`
2. change LIB_PATH point to the juliawebserver framework path, like `/home/cheney/juliawebserver` 
    (if you copy juliawebserver to julia's directory. you can set it `./juliawebserver`)
3. `cd example`
4. `julia main.j`
5. wait for a moment and it will display the port , default 4444
6. now you can browse `http://localhost:4444`

## WARNING
All the page must use UTF-8 encoding.

## Now support
- **send status:** you can send the http status code like "404", "200" etc.
- **get argument:** get the POST argument and auto use URLDecode,support Chinese
- **set/get cookie** now support.
- **template** support template(extend, for, if).

## TODO

- **support asynchronous**

## Bind NginX

1. `cd /etc/nginx/sites-available/`
2. `sudo nano default` (you can choose other file)

    server {
    
        listen 80;
        server_name julia;
        index index.html index.htm;
        location / {
            proxy_pass http://127.0.0.1:4444;
            proxy_set_header Host $host;
        }
    }


