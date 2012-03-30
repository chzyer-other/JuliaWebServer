is_extend = true
function html()
extend = "base"
title = """welcome to julia webserver"""
bar = """source loop"""
body = """
<h2>loop</h2>
<h3>loop source:</h3>
<code>
{&#37; for i=1:10 %}
<li><a href=\"javascript:;\">item{{ i }}</a></li>
{&#37; end %}
</code>
<h3>real source:</h3>
<code>
	"""
for i=1:10
body = strcat(body, """
	<li><a href=\"javascript:;\">item$(i)</a></li>
	""")
end
body = strcat(body, """
</code>
<h3>html view:</h3>
<div class=\"viewcode\">
	""")
for i=1:10
body = strcat(body, """
	<li><a href=\"javascript:;\">item$(i)</a></li>
	""")
end
body = strcat(body, """
</div>
""")
js = """
function replace(str, reg, news){
	return str.replace(new RegExp(reg, \"gm\"), news)
}

\$(\"code\").each(function(){
	html = \$(this).html();
	new_html = html;
	new_html = replace(new_html, \"<\", \"&lt;\")
	new_html = replace(new_html, \">\", \"&gt;\")
	if (new_html[0] == \"\\n\"){
		new_html = new_html.substring(1)
	}
	new_html = replace(new_html, \"\\n\", \"<br>\")
	\$(this).html('').html(new_html).wrap(\"<div class='code'></div>\")

})

"""
	{"extend"=>extend,"title"=>title,"bar"=>bar,"body"=>body,"js"=>js,}
end