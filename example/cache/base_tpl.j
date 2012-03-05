is_extend = false
function html(data)
title = has(data, "title") ? data["title"] : """你好, 这里是base的标题"""
body = has(data, "body") ? data["body"] : """
	"""
"""<html>
<head>
	<title>$(title)</title>
</head>
<body>
	$(body)
	
	$(time())
</body>
</html>"""
end