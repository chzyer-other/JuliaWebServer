is_extend = true
function html()
extend = "base"
title = """thisisnewtitle"""
body = """
	"""
for i=1:10
body = strcat(body, """
	<a href=\"javascript:;\">$(i)d</a>
	""")
end
if 1==2
body = strcat(body, """
		1 = 2
	""")
elseif 2==2
body = strcat(body, """
		""")
if 1==1
body = strcat(body, """
			哈拉拉	
		""")
else
body = strcat(body, """
		也是
		""")
end
else
body = strcat(body, """
		1 != 2<br>
		salflkjsadlfkjasdf
	""")
end
	{"extend"=>extend,"title"=>title,"body"=>body,}
end