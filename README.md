
a framework to make building website more easily 

<a name="JuliaWebServer-a-webserver-for-julia"/>
## JuliaWebServer : a webserver for julia
Base on julia <https://github.com/JuliaLang/julia>

## WARNING
All the page must use UTF-8 encoding.

## Now support
- **send status:** you can send the http status code like "404", "200" etc.
- **get argument:** get the POST argument and auto use URLDecode,support Chinese

## TODO

- **support cookie**
- **support asynchronous**
- **support template**

## Example

see the sub directory "example" .

1. open the file `julia_webserver_base.j`
2. change LIB_PATH point to the juliawebserver framework path, like `/home/cheney/juliawebserver`
3. `cd example`
4. `julia main.j`
5. wait for a moment and it will display the port , default 4444
6. now you can browse `http://localhost:4444`