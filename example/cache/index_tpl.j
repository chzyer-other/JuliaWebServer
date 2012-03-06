is_extend = true
function html()
extend = "base"
title = """thisisnewtitle"""
body = """
<a href=\"javascript\"><img src=\"http://img2.douban.com/pics/fw2douban_s.png\" alt=\"推荐到豆瓣\" /></a>
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
body = strcat(body, """
	<img src=\"http://img2.douban.com/pics/fw2douban_s.png\" alt=\"推荐到豆瓣\" />
""")
	{"extend"=>extend,"title"=>title,"body"=>body,}
end