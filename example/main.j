load("../julia_webserver_base.j")
load("sub.j")

mainHandler = Handler(
	function (f)
		
		f.write(f.get_cookie("user", nothing))
		f.write(f.get_cookie("_xsrf", nothing))
		f.write("欢迎通过get方式访问main")
	end
	, 
	function (f)
		c = f.get_argument("request", "2")
		f.set_cookie("user", c)
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