load("../julia_webserver_base.j")
load("sub.j")

mainHandler = Handler(
	function (f)
		f.render("index")
	end
	, 
	function (f)
		c = f.get_argument("request", "2")
		f.set_cookie("user", c)
		f.write("thanks for post data $c")	
	end
)

SourceLoopHandler = Handler(
	function (f)
		f.render("source/loop")
	end,
	nothing
)

__handlers = [
    (r"/", mainHandler),
    (r"/source/loop", SourceLoopHandler),
    (r"/[^/]+", subHandler),
]
_setting = {
	debug = true
}

loop()