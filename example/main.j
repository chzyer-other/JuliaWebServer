load("../julia_webserver_base.j")
load("sub.j")

mainHandler = Handler(
	function (f)
		f.write("welcome to main")
	end
	, 
	function (f)
		f.write("thanks for post data")	
	end
)


__handlers = [
    (r"/", mainHandler),
    (r"/[^/]+", subHandler)
]
_setting = {
	
}

loop()