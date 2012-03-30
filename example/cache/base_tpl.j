is_extend = false
function html(data)
title = has(data, "title") ? data["title"] : """hello world"""
js = has(data, "js") ? data["js"] : """"""
body = has(data, "body") ? data["body"] : """asdf"""
"""<!DOCTYPE HTML>
<html lang=zh-CN>
<head>
	<meta charset=\"utf-8\">
	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
	<link href=\"/css/base.css\" media=\"screen, projection\" rel=\"stylesheet\" type=\"text/css\" />
	<title>$(title)</title>	
	<script src=\"/js/jquery.min.js\"></script>
</head>

<body>
	<div id=\"topbar\">
		<div class=\"container\">
			<span style=\"float:left\"><a href=\"/\">JuliaWebServer</a></span>

			<div class=\"banner\">
				<li>Index</li>
			</div>
			<div style=\"clear:both\"></div>
		</div>
		
	</div>
	
	<div id=\"body\">$(body)</div>

	<div id=\"footbar\">
		<div class=\"container\">
			<span style=\"float:right\">Powered By Chzyer</span>
		Here is the footer
		</div>
	</div>

	<script>
	$(js)
	</script>
</body>
</html>"""
end