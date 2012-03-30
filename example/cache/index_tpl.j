is_extend = true
function html()
extend = "base"
title = """welcome to julia webserver"""
body = """
<div>This example will show you how to use template:</div>
<li><a href=\"/source/loop\">loop</a></li>

</form>
"""
	{"extend"=>extend,"title"=>title,"body"=>body,}
end