is_extend = false
function html(data)
bar = has(data, "bar") ? data["bar"] : """"""
title = has(data, "title") ? data["title"] : """hello world"""
js = has(data, "js") ? data["js"] : """"""
body = has(data, "body") ? data["body"] : """asdf"""
"""<!DOCTYPE HTML>\
<html lang=zh-CN>\
<head>\
	<meta charset=\"utf-8\">\
	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\
	<link href=\"/css/base.css\" media=\"screen, projection\" rel=\"stylesheet\" type=\"text/css\" />\
	<title>$(title)</title>	\
	<script src=\"/js/jquery.min.js\"></script>\
</head>\
<body>\
	<div id=\"topbar\">Welcome to JuliaWebServer</div>\
	<div id=\"header\"><a href=\"/\">JuliaWebServer</a></div>\
	<div id=\"bar\"><a href=\"/\">index</a> &rsaquo;  $(bar)</div>\
	<div id=\"body\">$(body)</div>\
	<div id=\"footbar\">Here is the footer</div>\
	<script>\
	$(js)\
	</script>\
</body>\
</html>"""
end