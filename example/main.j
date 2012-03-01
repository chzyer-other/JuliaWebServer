load("../julia_webserver_base.j")
load("sub.j")

mainHandler = Handler(
	function (f)
		println("白痴".data)
		f.write("欢迎通过get方式访问main")
	end
	, 
	function (f)
		c = f.get_argument("request", "2")
		f.write("thanks for post data $c")	
	end
)


__handlers = [
    (r"/", mainHandler),
    (r"/[^/]+", subHandler)
]
_setting = {
	debug = true
}

loop()
a = "%E7%99%BD%E7%97%B4"
c = URLDecode(a)
println(c)